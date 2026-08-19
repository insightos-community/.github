#!/usr/bin/env bash
# Compile vendor skill_library Python → .so (Cython). Operates ONLY under vendor/.
# Fallback for failed modules: keep original .py (listed in .cython_failed.txt).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENDOR_ABILITY="${ALLINONE_DIR}/vendor/ability"
VENDOR_ROOT="${1:-${VENDOR_ABILITY}/v1/skill_library}"

COMPILE_VENV="${VENDOR_ABILITY}/.compile-venv"
PY="${PYTHON:-}"
if [[ -z "${PY}" ]]; then
  if [[ -x "${COMPILE_VENV}/bin/python" ]]; then
    PY="${COMPILE_VENV}/bin/python"
  else
    PY=python3
  fi
fi

log() { printf '[compile-skill-library] %s\n' "$*"; }
die() { printf '[compile-skill-library] ERROR: %s\n' "$*" >&2; exit 1; }

[[ -d "${VENDOR_ROOT}" ]] || die "missing skill_library: ${VENDOR_ROOT}"

# Ensure compile venv with Cython + numpy matching headers
if [[ ! -x "${COMPILE_VENV}/bin/python" ]]; then
  log "creating compile venv"
  python3 -m venv "${COMPILE_VENV}"
fi
"${COMPILE_VENV}/bin/pip" install -q -U pip setuptools wheel 'Cython>=3' 'numpy<2'
PY="${COMPILE_VENV}/bin/python"

BUILD_DIR="$(dirname "${VENDOR_ROOT}")/.skill_library_build"
OUT_DIR="$(dirname "${VENDOR_ROOT}")/skill_library.compiled"
rm -rf "${BUILD_DIR}" "${OUT_DIR}"
mkdir -p "${BUILD_DIR}" "${OUT_DIR}"

log "copy tree → build"
rsync -a \
  --exclude '__pycache__/' \
  --exclude '*.pyc' \
  --exclude 'Grab_Up_bak/' \
  --exclude 'VLA/' \
  --exclude 'skill_generation_tool/' \
  --exclude 'docs/' \
  "${VENDOR_ROOT}/" "${BUILD_DIR}/"

FAILED_LIST="${OUT_DIR}/.cython_failed.txt"
: > "${FAILED_LIST}"
OK_LIST="${OUT_DIR}/.cython_ok.txt"
: > "${OK_LIST}"

log "cythonize each module with ${PY}"
CYTHONIZE="$(dirname "${PY}")/cythonize"
[[ -x "${CYTHONIZE}" ]] || die "missing cythonize at ${CYTHONIZE}"

mapfile -t PY_FILES < <(find "${BUILD_DIR}/Atom" "${BUILD_DIR}/Behavioral" "${BUILD_DIR}/Solver" \
  -name '*.py' 2>/dev/null | sort)

total=${#PY_FILES[@]}
log "candidates=${total}"
idx=0
for f in "${PY_FILES[@]}"; do
  idx=$((idx + 1))
  rel="${f#"${BUILD_DIR}/"}"
  if (cd "$(dirname "$f")" && "${CYTHONIZE}" -i -3 -q "$(basename "$f")" >/tmp/cythonize.out 2>/tmp/cythonize.err); then
    echo "${rel}" >> "${OK_LIST}"
    printf '  [%d/%d] OK %s\n' "$idx" "$total" "$rel"
  else
    echo "${rel}" >> "${FAILED_LIST}"
    printf '  [%d/%d] FAIL %s\n' "$idx" "$total" "$rel"
    tail -n 3 /tmp/cythonize.err | sed 's/^/    /' || true
  fi
done

log "materialize release tree"
rsync -a \
  --exclude 'build/' \
  --exclude '*.c' \
  --exclude '*.cpp' \
  --exclude '__pycache__/' \
  "${BUILD_DIR}/" "${OUT_DIR}/"

# Delete .py when a corresponding .so exists; keep .py for failures (importability)
"${PY}" - "${OUT_DIR}" <<'PY'
from pathlib import Path
root = Path(__import__("sys").argv[1])
removed = kept = 0
for py in list(root.rglob("*.py")):
    stem = py.stem
    parent = py.parent
    sos = list(parent.glob(f"{stem}.*.so")) + list(parent.glob(f"{stem}.so"))
    if sos:
        py.unlink(missing_ok=True)
        removed += 1
    else:
        kept += 1
print(f"stripped_py={removed} kept_py_fallback={kept}")
PY

cp -a "${FAILED_LIST}" "${OUT_DIR}/.cython_failed.txt" 2>/dev/null || true
cp -a "${OK_LIST}" "${OUT_DIR}/.cython_ok.txt" 2>/dev/null || true

ORIG_BACKUP="$(dirname "${VENDOR_ROOT}")/skill_library.src"
if [[ ! -d "${ORIG_BACKUP}" ]]; then
  log "rename original vendor skill_library → skill_library.src"
  mv "${VENDOR_ROOT}" "${ORIG_BACKUP}"
else
  # refresh backup if we were re-compiling from live tree
  if [[ "${VENDOR_ROOT}" != "${ORIG_BACKUP}" ]]; then
    rm -rf "${VENDOR_ROOT}"
  fi
fi
mv "${OUT_DIR}" "${VENDOR_ROOT}"

log "smoke import GrabUp"
PYTHONPATH="${VENDOR_ROOT}" "${PY}" - <<'PY' || true
try:
    from Behavioral.Grab_Up.Galaxea_R1Pro.scripts.main import GrabUp
    print("GrabUp OK", GrabUp)
except Exception as e:
    print("GrabUp import error:", type(e).__name__, e)
PY

ok_n=$(wc -l < "${VENDOR_ROOT}/.cython_ok.txt" | tr -d ' ')
fail_n=$(wc -l < "${VENDOR_ROOT}/.cython_failed.txt" | tr -d ' ')
log "done: ok=${ok_n} failed=${fail_n} path=${VENDOR_ROOT}"
du -sh "${VENDOR_ROOT}" || true
