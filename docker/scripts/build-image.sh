#!/usr/bin/env bash
# Build the all-in-one release image from staged artifacts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "${ALLINONE_DIR}/VERSION" 2>/dev/null || echo "1.0.0")"
IMAGE="${RELEASE_IMAGE:-InsightSemantic:${VERSION}}"
STAGING="${STAGING_DIR:-${ALLINONE_DIR}/staging}"
PLATFORM="${TARGET_PLATFORM:-linux/amd64}"

log() { printf '[build-image] %s\n' "$*"; }

if [[ "${SKIP_STAGE:-0}" != "1" ]]; then
  bash "${SCRIPT_DIR}/stage-release.sh"
fi

[[ -d "${STAGING}/bin" ]] || { echo "staging missing; run stage-release.sh first" >&2; exit 1; }

log "building ${IMAGE} (${PLATFORM})"
docker build \
  --platform "${PLATFORM}" \
  -f "${ALLINONE_DIR}/Dockerfile" \
  --build-arg RELEASE_VERSION="${VERSION}" \
  -t "${IMAGE}" \
  -t "InsightSemantic:latest" \
  "${STAGING}"

log "done: ${IMAGE} (+ InsightSemantic:latest)"
docker image inspect "${IMAGE}" --format '{{.Id}} {{.Architecture}} {{.Size}}'
