#!/usr/bin/env bash
# Stage build artifacts from sibling workspaces into JushiPublic/docker/allinone/staging
# for the all-in-one release image.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd "${ALLINONE_DIR}/../../.." && pwd)}"
VERSION="$(tr -d '[:space:]' < "${ALLINONE_DIR}/VERSION" 2>/dev/null || echo "1.0.0")"
STAGING="${STAGING_DIR:-${ALLINONE_DIR}/staging}"
PLATFORM="${TARGET_PLATFORM:-linux/amd64}"

SEMANTIC_DIR="${SEMANTIC_DIR:-${WORKSPACE_ROOT}/semantic-framework}"
STUDIO_DIR="${STUDIO_DIR:-${WORKSPACE_ROOT}/studio-backend-framework}"
MUJOCO_DIR="${MUJOCO_DIR:-${WORKSPACE_ROOT}/plugin-mujoco}"

log() { printf '[stage-release] %s\n' "$*"; }
die() { printf '[stage-release] ERROR: %s\n' "$*" >&2; exit 1; }

need_file() { [[ -f "$1" ]] || die "missing file: $1"; }
need_dir() { [[ -d "$1" ]] || die "missing dir: $1"; }

git_sha() {
  local dir="$1"
  git -C "$dir" rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

log "workspace=${WORKSPACE_ROOT}"
log "staging=${STAGING}"
log "version=${VERSION} platform=${PLATFORM}"

need_dir "$SEMANTIC_DIR"
need_dir "$STUDIO_DIR"
need_dir "$MUJOCO_DIR"

rm -rf "${STAGING}"
mkdir -p \
  "${STAGING}/bin" \
  "${STAGING}/configs" \
  "${STAGING}/web" \
  "${STAGING}/services/semantic-map" \
  "${STAGING}/mujoco" \
  "${STAGING}/runtime" \
  "${STAGING}/nginx" \
  "${STAGING}/meta"

# ---------- Semantic binaries ----------
log "building semantic-server / semantic-pilot"
(
  cd "$SEMANTIC_DIR"
  make server pilot VERSION="${VERSION}"
)
need_file "${SEMANTIC_DIR}/bin/semantic-server"
need_file "${SEMANTIC_DIR}/bin/semantic-pilot"
cp -a "${SEMANTIC_DIR}/bin/semantic-server" "${STAGING}/bin/"
cp -a "${SEMANTIC_DIR}/bin/semantic-pilot" "${STAGING}/bin/"

# ---------- Semantic web ----------
log "building semantic-web"
(
  cd "$SEMANTIC_DIR"
  if [[ ! -d web/node_modules ]]; then
    make web-install
  fi
  cd web
  if npm run | grep -q 'build:prod'; then
    npm run build:prod
  else
    npm run build
  fi
)
WEB_DIST=""
for candidate in \
  "${SEMANTIC_DIR}/web/dist" \
  "${SEMANTIC_DIR}/.output/web/dist"
do
  if [[ -f "${candidate}/index.html" ]]; then
    WEB_DIST="$candidate"
    break
  fi
done
[[ -n "$WEB_DIST" ]] || die "semantic-web dist not found"
cp -a "${WEB_DIST}/." "${STAGING}/web/"

# ---------- Semantic map binary + configs ----------
log "building semantic-map binary"
(
  cd "$SEMANTIC_DIR"
  make map-binary
)
need_file "${SEMANTIC_DIR}/.output/semantic-map/semantic-map"
cp -a "${SEMANTIC_DIR}/.output/semantic-map/semantic-map" "${STAGING}/bin/semantic-map"

log "staging semantic-map configs (demo snapshots; no app source)"
mkdir -p "${STAGING}/services/semantic-map"
if [[ -d "${SEMANTIC_DIR}/services/semantic-map/configs" ]]; then
  cp -a "${SEMANTIC_DIR}/services/semantic-map/configs" "${STAGING}/services/semantic-map/"
fi
if [[ -f "${SEMANTIC_DIR}/services/semantic-map/info.json" ]]; then
  cp -a "${SEMANTIC_DIR}/services/semantic-map/info.json" "${STAGING}/services/semantic-map/"
fi

# ---------- Ability frameworks (vendor copy only; never mutate ability_simu) ----------
log "preparing ability vendor + stage"
VENDOR_ABILITY="${ALLINONE_DIR}/vendor/ability"
if [[ "${SKIP_ABILITY_SYNC:-0}" != "1" ]] || [[ ! -d "${VENDOR_ABILITY}/v1" ]]; then
  bash "${SCRIPT_DIR}/sync-ability-vendor.sh"
fi
if [[ "${SKIP_ABILITY_COMPILE:-0}" != "1" ]]; then
  # Compile once from v1, then reuse for v2 if trees match after sync.
  bash "${SCRIPT_DIR}/compile-skill-library.sh" "${VENDOR_ABILITY}/v1/skill_library"
  if [[ -d "${VENDOR_ABILITY}/v1/skill_library" ]]; then
    rm -rf "${VENDOR_ABILITY}/v2/skill_library" "${VENDOR_ABILITY}/v2/skill_library.src"
    cp -a "${VENDOR_ABILITY}/v1/skill_library" "${VENDOR_ABILITY}/v2/skill_library"
    if [[ -d "${VENDOR_ABILITY}/v1/skill_library.src" ]]; then
      cp -a "${VENDOR_ABILITY}/v1/skill_library.src" "${VENDOR_ABILITY}/v2/skill_library.src"
    fi
  fi
fi
bash "${SCRIPT_DIR}/patch-ability-for-docker.sh"

mkdir -p "${STAGING}/ability/wheels" "${STAGING}/ability/v1" "${STAGING}/ability/v2"
# Slim stage: framework + compiled skill_library (drop src backup from image)
for ver in v1 v2; do
  mkdir -p "${STAGING}/ability/${ver}/skill_ability"
  cp -a "${VENDOR_ABILITY}/${ver}/skill_library" "${STAGING}/ability/${ver}/"
  # framework without bulky runtime logs/dbs
  rsync -a \
    --exclude 'log/' \
    --exclude 'databases/' \
    --exclude '__pycache__/' \
    "${VENDOR_ABILITY}/${ver}/skill_ability/framework/" \
    "${STAGING}/ability/${ver}/skill_ability/framework/"
done
cp -a "${ALLINONE_DIR}/configs/ability-requirements-cpu.txt" "${STAGING}/ability/requirements-cpu.txt"
# wheels / tool from vendor v1 requirments
REQ_DIR="${VENDOR_ABILITY}/v1/skill_ability/requirments"
if [[ -d "${REQ_DIR}" ]]; then
  cp -a "${REQ_DIR}"/ability_py-*.whl "${STAGING}/ability/wheels/" 2>/dev/null || true
  cp -a "${REQ_DIR}/ability_tool" "${STAGING}/ability/wheels/" 2>/dev/null || true
fi
need_file "${STAGING}/ability/v1/skill_ability/framework/AbilityFramework"
need_file "${STAGING}/ability/v2/skill_ability/framework/AbilityFramework"
need_file "${STAGING}/ability/requirements-cpu.txt"

# ---------- Community seed project + map snapshot ----------
# Official community depalletize project (UUID fixed; aligns with frontend featured).
# Prefer the committed demo under docker/allinone/seed/community/, then refresh from
# local workspace / semantic-map snapshot when available.
COMMUNITY_PROJECT_UUID="${COMMUNITY_PROJECT_UUID:-9bbdc181-26ad-486a-8e57-fe9ffe5505d2}"
COMMITTED_SEED="${ALLINONE_DIR}/seed/community"
COMMUNITY_SNAPSHOT="${COMMUNITY_SNAPSHOT:-${SEMANTIC_DIR}/services/semantic-map/output/semantic-map/map-snapshot.json}"
if [[ ! -f "${COMMUNITY_SNAPSHOT}" && -f "${COMMITTED_SEED}/map-snapshot.json" ]]; then
  COMMUNITY_SNAPSHOT="${COMMITTED_SEED}/map-snapshot.json"
fi
COMMUNITY_PROJECT_SRC="${COMMUNITY_PROJECT_SRC:-${STUDIO_DIR}/plugins/plugin-semantic-ide/studio_data/workspace/${COMMUNITY_PROJECT_UUID}}"
if [[ ! -d "${COMMUNITY_PROJECT_SRC}" ]]; then
  COMMUNITY_PROJECT_SRC="${WORKSPACE_ROOT}/plugin-semantic-ide/studio_data/workspace/${COMMUNITY_PROJECT_UUID}"
fi
if [[ ! -d "${COMMUNITY_PROJECT_SRC}" && -d "${COMMITTED_SEED}/project/${COMMUNITY_PROJECT_UUID}" ]]; then
  COMMUNITY_PROJECT_SRC="${COMMITTED_SEED}/project/${COMMUNITY_PROJECT_UUID}"
fi
need_file "${COMMUNITY_SNAPSHOT}"
log "staging community seed project=${COMMUNITY_PROJECT_UUID}"
mkdir -p \
  "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/scenes" \
  "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/skills" \
  "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/maps/simulation" \
  "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/maps/robot" \
  "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/configs" \
  "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/abilitys"
if [[ -d "${COMMITTED_SEED}" ]]; then
  # Start from committed demo so image builds stay reproducible without local workspace.
  cp -a "${COMMITTED_SEED}/." "${STAGING}/seed/community/"
fi
cp -a "${COMMUNITY_SNAPSHOT}" "${STAGING}/seed/community/map-snapshot.json"
cp -a "${COMMUNITY_SNAPSHOT}" "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/maps/simulation/map-snapshot.json"
cp -a "${COMMUNITY_SNAPSHOT}" "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/maps/map-snapshot.json"
if [[ -d "${COMMUNITY_PROJECT_SRC}" ]]; then
  # Prefer local workspace extras (skills/scenes/configs) when available; maps always from authoritative snapshot.
  for sub in scenes skills configs abilitys; do
    if [[ -d "${COMMUNITY_PROJECT_SRC}/${sub}" ]]; then
      cp -a "${COMMUNITY_PROJECT_SRC}/${sub}/." "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/${sub}/" || true
    fi
  done
fi
cat > "${STAGING}/seed/community/project/${COMMUNITY_PROJECT_UUID}/manifest.json" <<EOF
{
  "project_uuid": "${COMMUNITY_PROJECT_UUID}",
  "name": "拆码垛项目",
  "simulation_platform": "mujoco",
  "directories": ["scenes", "skills", "maps", "configs", "abilitys"],
  "bindings": {
    "mujoco_scene": {
      "status": "ready",
      "external_ref": "${COMMUNITY_PROJECT_UUID}",
      "scene_name": "palletizing_depalletizing_001"
    },
    "map_simulation": {
      "status": "pending",
      "external_ref": "${COMMUNITY_PROJECT_UUID}",
      "provider_id": "semantic-map-simulation",
      "service_class": "simulation",
      "binding_version": 1
    }
  }
}
EOF
# Keep seed readable inside the image (source snapshots are often mode 0600).
find "${STAGING}/seed/community" -type f -exec chmod a+r {} +
find "${STAGING}/seed/community" -type d -exec chmod a+rx {} +

# ---------- Semantic release configs ----------
log "staging semantic configs"
mkdir -p "${STAGING}/configs/semantic"
cp -a "${SEMANTIC_DIR}/deploy/release/configs/." "${STAGING}/configs/semantic/"

# Keep skill/plugin/template layouts expected by semantic-server release config
mkdir -p "${STAGING}/configs/skills" "${STAGING}/configs/plugins" "${STAGING}/templates"
if [[ -d "${SEMANTIC_DIR}/templates" ]]; then
  cp -a "${SEMANTIC_DIR}/templates/." "${STAGING}/templates/" || true
fi
if [[ -d "${SEMANTIC_DIR}/configs/skills" ]]; then
  cp -a "${SEMANTIC_DIR}/configs/skills/." "${STAGING}/configs/skills/" || true
fi
if [[ -d "${SEMANTIC_DIR}/configs/plugins" ]]; then
  cp -a "${SEMANTIC_DIR}/configs/plugins/." "${STAGING}/configs/plugins/" || true
fi
# ensure non-empty templates dir for Docker COPY
touch "${STAGING}/templates/.keep"

# ---------- Studio integrated binary ----------
log "building studio sbf-integrated (plugin-semantic-ide)"
(
  cd "$STUDIO_DIR"
  # Avoid normalize-plugin-replaces here: absolute replaces can conflict with
  # relative ../../ replaces already present in sibling Go plugins under go.work.
  make build-release-integrated
)
need_file "${STUDIO_DIR}/bin/sbf-integrated"
cp -a "${STUDIO_DIR}/bin/sbf-integrated" "${STAGING}/bin/"
cp -a "${STUDIO_DIR}/configs/config.release-integrated.yaml" "${STAGING}/configs/studio-integrated.yaml"

# ---------- MuJoCo deb + web-viewer ----------
DEB_PATH="${MUJOCO_DEB:-}"
if [[ -z "$DEB_PATH" ]]; then
  DEB_PATH="$(ls -1t "${MUJOCO_DIR}/dist/deb"/plugin-mujoco_*_amd64.deb 2>/dev/null | head -n1 || true)"
fi
[[ -n "$DEB_PATH" && -f "$DEB_PATH" ]] || die "mujoco deb not found under ${MUJOCO_DIR}/dist/deb (set MUJOCO_DEB=...)"
log "staging mujoco deb: ${DEB_PATH}"
cp -a "$DEB_PATH" "${STAGING}/mujoco/plugin-mujoco.deb"
cp -a "${MUJOCO_DIR}/deploy/release/comm_config.yaml" "${STAGING}/configs/comm_config.yaml"

log "building mujoco web-viewer"
(
  cd "${MUJOCO_DIR}/web-viewer"
  if [[ ! -d node_modules ]]; then
    npm install --no-audit --no-fund
  fi
  npm run build:standalone
)
need_dir "${MUJOCO_DIR}/web-viewer/dist"
mkdir -p "${STAGING}/mujoco/web-viewer"
cp -a "${MUJOCO_DIR}/web-viewer/dist" "${STAGING}/mujoco/web-viewer/"

# ---------- Runtime / nginx from allinone package ----------
cp -a "${ALLINONE_DIR}/runtime/." "${STAGING}/runtime/"
cp -a "${ALLINONE_DIR}/nginx/." "${STAGING}/nginx/"
cp -a "${ALLINONE_DIR}/configs/supervisord.conf" "${STAGING}/configs/" 2>/dev/null || true
# semantic configs already copied; also copy allinone overlay configs if any
if [[ -d "${ALLINONE_DIR}/configs" ]]; then
  # copy non-conflicting overlay files
  for f in "${ALLINONE_DIR}/configs"/*; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f")"
    if [[ "$base" == "semantic" ]]; then
      continue
    fi
    cp -a "$f" "${STAGING}/configs/"
  done
fi

# ---------- Metadata ----------
DEB_VERSION="$(dpkg-deb -f "$DEB_PATH" Version 2>/dev/null || echo unknown)"
cat > "${STAGING}/meta/MANIFEST.json" <<EOF
{
  "version": "${VERSION}",
  "platform": "${PLATFORM}",
  "built_at": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "components": {
    "semantic-framework": {"sha": "$(git_sha "$SEMANTIC_DIR")", "path": "${SEMANTIC_DIR}"},
    "studio-backend-framework": {"sha": "$(git_sha "$STUDIO_DIR")", "path": "${STUDIO_DIR}"},
    "plugin-mujoco": {"sha": "$(git_sha "$MUJOCO_DIR")", "deb_version": "${DEB_VERSION}", "deb": "$(basename "$DEB_PATH")"}
  }
}
EOF

log "staging complete:"
du -sh "${STAGING}" || true
find "${STAGING}/bin" -type f -printf '  %p\n'
ls -lh "${STAGING}/mujoco/plugin-mujoco.deb"
log "manifest: ${STAGING}/meta/MANIFEST.json"
