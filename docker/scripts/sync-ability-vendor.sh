#!/usr/bin/env bash
# Read-only sync: ability_simu → docker/allinone/vendor/ability
# NEVER writes back to ability_simu.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd "${ALLINONE_DIR}/../../.." && pwd)}"
VENDOR="${ALLINONE_DIR}/vendor/ability"

ABILITY_V1_SRC="${ABILITY_V1_SRC:-${WORKSPACE_ROOT}/ability_simu/skill-Ability-simu-1}"
ABILITY_V2_SRC="${ABILITY_V2_SRC:-${WORKSPACE_ROOT}/ability_simu/skill-Ability-simu-2}"

log() { printf '[sync-ability-vendor] %s\n' "$*"; }
die() { printf '[sync-ability-vendor] ERROR: %s\n' "$*" >&2; exit 1; }

[[ -d "${ABILITY_V1_SRC}" ]] || die "missing ${ABILITY_V1_SRC}"
[[ -d "${ABILITY_V2_SRC}" ]] || die "missing ${ABILITY_V2_SRC}"

RSYNC_EXCLUDES=(
  --exclude '.git/'
  --exclude 'output/'
  --exclude '**/__pycache__/'
  --exclude '**/*.pyc'
  --exclude 'skill_ability/framework/log/'
  --exclude 'skill_ability/framework/databases/'
  --exclude 'skill_library/Behavioral/Grab_Up_bak/'
  --exclude 'skill_library/Behavioral/VLA/'
  --exclude 'skill_library/skill_generation_tool/'
  --exclude 'skill_library/docs/'
  --exclude 'Docs/'
  --exclude '*.tar.gz'
)

sync_one() {
  local src="$1" dest="$2" label="$3"
  log "sync ${label}: ${src} → ${dest}"
  mkdir -p "${dest}"
  rsync -a --delete "${RSYNC_EXCLUDES[@]}" "${src}/" "${dest}/"
  # Sanity: never allow a symlink escape that points back for writes in our scripts
  [[ -x "${dest}/skill_ability/framework/AbilityFramework" ]] \
    || [[ -x "${dest}/skill_ability/AbilityFramework" ]] \
    || die "${label}: AbilityFramework binary missing"
  [[ -d "${dest}/skill_library" ]] || die "${label}: skill_library missing"
}

mkdir -p "${VENDOR}"
sync_one "${ABILITY_V1_SRC}" "${VENDOR}/v1" "v1"
sync_one "${ABILITY_V2_SRC}" "${VENDOR}/v2" "v2"

# Touch a marker so stage can detect freshness
cat > "${VENDOR}/MANIFEST.txt" <<EOF
synced_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
v1_src=${ABILITY_V1_SRC}
v2_src=${ABILITY_V2_SRC}
note=vendor copy only; do not modify ability_simu originals
EOF

log "done. vendor=${VENDOR}"
du -sh "${VENDOR}/v1" "${VENDOR}/v2" || true
