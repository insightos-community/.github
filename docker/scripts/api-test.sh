#!/usr/bin/env bash
# API functional checks through the published frontend port (bridge mode).
set -euo pipefail

BASE="${SMOKE_BASE_URL:-http://127.0.0.1:${FRONTEND_PORT:-80}}"
CONTAINER="${RELEASE_CONTAINER_NAME:-InsightSemantic}"
failed=0

pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*"; failed=1; }

json_get() {
  local url="$1"
  curl -fsS --max-time 10 "$url"
}

echo "=== API functional test via ${BASE} ==="

# 1) Aggregate health
if curl -fsS --max-time 5 "${BASE}/healthz" | grep -Eq 'ok|degraded|healthy|status'; then
  pass "GET /healthz"
else
  fail "GET /healthz"
fi

# 2) Semantic health
sem="$(curl -fsS --max-time 8 "${BASE}/api/v1/health" || true)"
if echo "$sem" | grep -Eqi 'ok|healthy|status|version|true'; then
  pass "GET /api/v1/health -> ${sem:0:120}"
else
  fail "GET /api/v1/health -> ${sem:0:200}"
fi

# 3) Semantic devices (pilots should register)
devices="$(curl -fsS --max-time 8 "${BASE}/api/v1/devices" || true)"
if echo "$devices" | grep -Eqi 'device|mock|robot|items|total|\[' ; then
  pass "GET /api/v1/devices"
else
  # some deployments wrap differently; accept 200 with body
  code="$(curl -sS -o /tmp/devices.json -w '%{http_code}' --max-time 8 "${BASE}/api/v1/devices" || echo 000)"
  if [[ "$code" == "200" ]]; then
    pass "GET /api/v1/devices (http 200)"
  else
    fail "GET /api/v1/devices (http $code)"
  fi
fi

# 4) Studio gateway + semantic-ide MCP (401 without auth still proves route exists)
code="$(curl -sS -o /tmp/studio-mcp.json -w '%{http_code}' --max-time 8 "${BASE}/api/v1/semantic-studio/mcp/health" || echo 000)"
if [[ "$code" =~ ^2 ]] || [[ "$code" == "401" ]]; then
  pass "GET /api/v1/semantic-studio/mcp/health ($code)"
else
  fail "GET /api/v1/semantic-studio/mcp/health ($code)"
fi

code="$(curl -sS -o /tmp/gw.json -w '%{http_code}' --max-time 8 "${BASE}/gateway/mcp/servers" || echo 000)"
if [[ "$code" =~ ^2 ]]; then
  pass "GET /gateway/mcp/servers ($code)"
else
  fail "GET /gateway/mcp/servers ($code)"
fi

# 5) MuJoCo HTTP (viewer required; MCP optional on older debs)
code="$(curl -sS -o /tmp/mujoco-mcp.json -w '%{http_code}' --max-time 8 "${BASE}/mcp/health" || echo 000)"
if [[ "$code" =~ ^2 ]]; then
  pass "GET /mcp/health ($code) $(head -c 160 /tmp/mujoco-mcp.json)"
else
  echo "WARN  GET /mcp/health ($code) — optional until mujoco deb includes MCP routes"
fi

code="$(curl -sS -o /tmp/viewer.html -w '%{http_code}' --max-time 8 "${BASE}/web-viewer/" || echo 000)"
if [[ "$code" =~ ^2 ]] && grep -qi 'html\|viewer\|mujoco' /tmp/viewer.html; then
  pass "GET /web-viewer/"
else
  fail "GET /web-viewer/ ($code)"
fi

# scene API surface (alive even without a loaded scene)
code="$(curl -sS -o /tmp/scene-objects.json -w '%{http_code}' --max-time 8 "${BASE}/api/v1/mujoco/scene/objects" || echo 000)"
if [[ "$code" =~ ^2 ]] || [[ "$code" == "400" ]]; then
  pass "GET /api/v1/mujoco/scene/objects ($code)"
else
  fail "GET /api/v1/mujoco/scene/objects ($code)"
fi

# 6) Map providers (internal; via docker exec)
map1="$(docker exec "$CONTAINER" curl -fsS --max-time 5 http://127.0.0.1:38083/api/v1/provider/health || true)"
map2="$(docker exec "$CONTAINER" curl -fsS --max-time 5 http://127.0.0.1:38084/api/v1/provider/health || true)"
if echo "$map1" | grep -Eqi 'ok|healthy|status|true'; then
  pass "map simulation :38083"
else
  fail "map simulation :38083 -> $map1"
fi
if echo "$map2" | grep -Eqi 'ok|healthy|status|true'; then
  pass "map robot :38084"
else
  fail "map robot :38084 -> $map2"
fi

# 7) MySQL / Redis / Pilot ports inside container
docker exec "$CONTAINER" bash -lc '
  set -e
  mysqladmin -h127.0.0.1 -P"${MYSQL_PORT:-13306}" -u"${MYSQL_USER:-studio}" -p"${MYSQL_PASSWORD:-insightos123}" ping >/dev/null
  redis-cli -h 127.0.0.1 ping | grep -q PONG
  (echo >/dev/tcp/127.0.0.1/9100)
  (echo >/dev/tcp/127.0.0.1/9200)
  (echo >/dev/tcp/127.0.0.1/9091)
' && pass "mysql/redis/pilot/rosbridge internal ports" || fail "internal ports"

# 8) Confirm host does NOT expose backend ports (bridge isolation)
leak=0
for p in 38080 18080 8000 13306 9100 9200 38083 38084; do
  if ss -ltn 2>/dev/null | grep -qE ":${p}\\s"; then
    # may be host-owned unrelated services; only fail if docker-proxy owns them for our container
    if docker port "$CONTAINER" 2>/dev/null | grep -q ":${p}"; then
      echo "LEAK  backend port ${p} published"
      leak=1
    fi
  fi
done
published="$(docker port "$CONTAINER" 2>/dev/null || true)"
echo "published ports: ${published:-<none>}"
if echo "$published" | grep -qvE '80/tcp|->'; then
  # allow only 80
  if echo "$published" | grep -qE ':[0-9]+' && ! echo "$published" | grep -Eq '80/tcp'; then
    fail "unexpected published ports: $published"
  else
    pass "only frontend port published"
  fi
else
  pass "frontend port published: $published"
fi
[[ "$leak" -eq 0 ]] || fail "backend port leak"

if [[ "$failed" -ne 0 ]]; then
  echo "API functional test FAILED"
  exit 1
fi
echo "API functional test PASSED"
