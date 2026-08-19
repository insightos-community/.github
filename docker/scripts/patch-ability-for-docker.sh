#!/usr/bin/env bash
# Patch CR / path references inside vendor/ability only (never ability_simu).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENDOR="${ALLINONE_DIR}/vendor/ability"

log() { printf '[patch-ability-for-docker] %s\n' "$*"; }
die() { printf '[patch-ability-for-docker] ERROR: %s\n' "$*" >&2; exit 1; }

[[ -d "${VENDOR}/v1" && -d "${VENDOR}/v2" ]] || die "run sync-ability-vendor.sh first"

patch_tree() {
  local root="$1" opt_prefix="$2"
  log "patch ${root} → ${opt_prefix}"
  # Rewrite YAML/text configs under framework
  find "${root}/skill_ability/framework" -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -print0 \
    | while IFS= read -r -d '' f; do
      # rosbridge / mujoco endpoints used in CRs
      sed -i \
        -e 's#ws://172\.130\.[0-9.]*:909[0-9]#ws://127.0.0.1:9091#g' \
        -e 's#ws://192\.168\.[0-9.]*:909[0-9]#ws://127.0.0.1:9091#g' \
        -e 's#http://172\.130\.[0-9.]*:8000#http://127.0.0.1:8000#g' \
        -e 's#http://localhost:8000#http://127.0.0.1:8000#g' \
        "$f"
      # Host absolute paths → container skill_library
      sed -i \
        -e "s#/home/jushi/workspace/ability_simu/[^\"']*/skill_library/#${opt_prefix}/skill_library/#g" \
        -e "s#/home/[^\"']*/skill_library/#${opt_prefix}/skill_library/#g" \
        -e "s#/home/jushi/workspace/ability_simu/[^\"']*/output#/opt/ability/output#g" \
        "$f"
    done

  # Patch Python package defaults (navsolver urdf fallback etc.)
  find "${root}/skill_ability/framework/packages" -type f -name 'ability.py' -print0 \
    | while IFS= read -r -d '' f; do
      sed -i \
        -e "s#/home/jushi/workspace/ability_simu/[^\"']*/skill_library/#${opt_prefix}/skill_library/#g" \
        -e "s#/home/[^\"']*/skill_library/#${opt_prefix}/skill_library/#g" \
        -e 's#ws://192\.168\.[0-9.]*:909[0-9]#ws://127.0.0.1:9091#g' \
        -e 's#http://172\.130\.[0-9.]*:8000#http://127.0.0.1:8000#g' \
        -e 's#"192\.168\.[0-9.]*"#"127.0.0.1"#g' \
        -e 's#"172\.130\.[0-9.]*"#"127.0.0.1"#g' \
        "$f"
      # Framework mirrors CRs under crs/_packages/**; top-level glob misses them and
      # abilities fall back to LAN robotUri defaults.
      sed -i \
        -e 's/crs_dir\.glob("\*\.yaml")/crs_dir.rglob("*.yaml")/g' \
        -e "s/crs_dir\.glob('\*\.yaml')/crs_dir.rglob('*.yaml')/g" \
        -e 's/crs_dir\.glob("\*\.yml")/crs_dir.rglob("*.yml")/g' \
        -e "s/crs_dir\.glob('\*\.yml')/crs_dir.rglob('*.yml')/g" \
        "$f"
    done
}
patch_tree "${VENDOR}/v1" "/opt/ability/v1"
patch_tree "${VENDOR}/v2" "/opt/ability/v2"

# Ensure ports
if [[ -f "${VENDOR}/v1/skill_ability/framework/config.yaml" ]]; then
  sed -i 's/http_port:.*/http_port: 48080/' "${VENDOR}/v1/skill_ability/framework/config.yaml"
fi
if [[ -f "${VENDOR}/v2/skill_ability/framework/config.yaml" ]]; then
  sed -i 's/http_port:.*/http_port: 48081/' "${VENDOR}/v2/skill_ability/framework/config.yaml"
fi

log "sample v1 grabup CR:"
grep -n 'robotUri\|yoloModelPath\|urdf_path' \
  "${VENDOR}/v1/skill_ability/framework/packages/mock.grabup.demo/1.0.0/crs/"*.yaml 2>/dev/null | head -5 || true
log "done"
