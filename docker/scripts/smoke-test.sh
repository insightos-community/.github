#!/usr/bin/env bash
# Host-side smoke test against bridge-mode all-in-one (frontend port only).
set -euo pipefail

BASE="${SMOKE_BASE_URL:-http://127.0.0.1:${FRONTEND_PORT:-80}}"
failed=0

check() {
  local name="$1" url="$2" expect_code="${3:-200}"
  local code
  code="$(curl -sS -o /tmp/jushi-smoke.body -w '%{http_code}' --max-time 8 "$url" || echo 000)"
  if [[ "$code" == "$expect_code" ]] || [[ "$code" =~ ^2 ]]; then
    echo "OK   $name ($code) $url"
  else
    echo "FAIL $name (http $code) $url"
    head -c 240 /tmp/jushi-smoke.body 2>/dev/null; echo
    failed=1
  fi
}

echo "=== smoke test via frontend ${BASE} ==="
check "nginx /healthz" "${BASE}/healthz"
check "semantic /api/v1/health" "${BASE}/api/v1/health"
check "studio gateway register surface" "${BASE}/gateway/services" "200"
# unauthenticated callers get 401; that still proves the route is mounted
code="$(curl -sS -o /tmp/jushi-smoke.body -w '%{http_code}' --max-time 8 "${BASE}/api/v1/semantic-studio/mcp/health" || echo 000)"
if [[ "$code" =~ ^2 ]] || [[ "$code" == "401" ]]; then
  echo "OK   studio semantic-ide mcp health ($code) ${BASE}/api/v1/semantic-studio/mcp/health"
else
  echo "FAIL studio semantic-ide mcp health (http $code)"
  failed=1
fi
# MuJoCo MCP may be missing in older packaged debs; web-viewer is the hard gate
code="$(curl -sS -o /tmp/jushi-smoke.body -w '%{http_code}' --max-time 8 "${BASE}/mcp/health" || echo 000)"
if [[ "$code" =~ ^2 ]]; then
  echo "OK   mujoco mcp health ($code) ${BASE}/mcp/health"
else
  echo "WARN mujoco mcp health (http $code) — optional until mujoco deb includes MCP routes"
fi
check "mujoco web-viewer" "${BASE}/web-viewer/"
check "web index" "${BASE}/"

# Internal-only services validated via docker exec doctor
if docker exec "${RELEASE_CONTAINER_NAME:-InsightSemantic}" /opt/InsightOS/runtime/doctor.sh doctor >/tmp/jushi-doctor.out 2>&1; then
  echo "OK   in-container doctor"
else
  echo "FAIL in-container doctor"
  cat /tmp/jushi-doctor.out
  failed=1
fi

if [[ "$failed" -ne 0 ]]; then
  echo "smoke FAILED"
  exit 1
fi
echo "smoke PASSED"
