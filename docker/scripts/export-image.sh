#!/usr/bin/env bash
# Export the all-in-one image as a loadable tar for offline install.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "${ALLINONE_DIR}/VERSION" 2>/dev/null || echo "1.0.0")"
IMAGE="${RELEASE_IMAGE:-InsightSemantic:${VERSION}}"
OUT_DIR="${EXPORT_DIR:-${ALLINONE_DIR}/dist}"
OUT_TAR="${OUT_DIR}/InsightSemantic-${VERSION}-linux-amd64.tar"

mkdir -p "${OUT_DIR}"
echo "[export-image] saving ${IMAGE} -> ${OUT_TAR}"
docker save -o "${OUT_TAR}" "${IMAGE}"
gzip -f -k "${OUT_TAR}"
ls -lh "${OUT_TAR}" "${OUT_TAR}.gz"
echo "[export-image] done"
