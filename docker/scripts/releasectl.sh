#!/usr/bin/env bash
# Operator CLI for the Insight all-in-one release package.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLINONE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ALLINONE_DIR}"

VERSION="$(tr -d '[:space:]' < VERSION 2>/dev/null || echo "1.0.0")"
export RELEASE_IMAGE="${RELEASE_IMAGE:-InsightSemantic:${VERSION}}"

if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose -f docker-compose.yaml)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE=(docker-compose -f docker-compose.yaml)
else
  echo "ERROR: neither 'docker compose' nor 'docker-compose' is available" >&2
  exit 1
fi

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  stage       Collect binaries/configs from sibling workspaces into staging/
  build       Stage (unless SKIP_STAGE=1) and build the all-in-one image
  export      docker save the image to dist/*.tar(.gz)
  load        docker load from dist tar (offline)
  pull        docker pull RELEASE_IMAGE
  up          Start the stack (requires .env)
  down        Stop the stack
  restart     Restart the stack
  logs [svc]  Tail container logs
  status      Show compose ps + health
  doctor      Run in-container diagnostics
  smoke       Run smoke checks against the published frontend port
  api-test    Run API functional checks via frontend + in-container probes
  help        Show this help

Env:
  RELEASE_IMAGE   default: InsightSemantic:\$(cat VERSION)
  WORKSPACE_ROOT  sibling repos root (default: ../../..)
  MUJOCO_DEB      explicit path to plugin-mujoco_*.deb
  SKIP_STAGE=1    skip staging during build
EOF
}

ensure_env() {
  if [[ ! -f .env ]]; then
    cp .env.example .env
    echo "[releasectl] created .env from .env.example — fill LLM keys before production use"
  fi
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  stage)
    bash scripts/stage-release.sh "$@"
    ;;
  build)
    bash scripts/build-image.sh "$@"
    ;;
  export)
    bash scripts/export-image.sh "$@"
    ;;
  load)
    TAR="${1:-}"
    if [[ -z "$TAR" ]]; then
      TAR="$(ls -1t dist/InsightSemantic-*-linux-amd64.tar 2>/dev/null | head -n1 || true)"
    fi
    [[ -n "$TAR" && -f "$TAR" ]] || { echo "no tar found; pass path or run export first" >&2; exit 1; }
    echo "[releasectl] docker load -i ${TAR}"
    docker load -i "$TAR"
    ;;
  pull)
    docker pull "${RELEASE_IMAGE}"
    ;;
  up)
    ensure_env
    "${COMPOSE[@]}" up -d
    ;;
  down)
    "${COMPOSE[@]}" down
    ;;
  restart)
    "${COMPOSE[@]}" restart
    ;;
  logs)
    "${COMPOSE[@]}" logs -f --tail=200 "$@"
    ;;
  status)
    "${COMPOSE[@]}" ps
    docker exec "${RELEASE_CONTAINER_NAME:-InsightSemantic}" /opt/InsightOS/runtime/doctor.sh status || true
    ;;
  doctor)
    docker exec "${RELEASE_CONTAINER_NAME:-InsightSemantic}" /opt/InsightOS/runtime/doctor.sh "$@"
    ;;
  smoke)
    bash scripts/smoke-test.sh "$@"
    ;;
  api-test)
    bash scripts/api-test.sh "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "unknown command: $cmd" >&2
    usage >&2
    exit 1
    ;;
esac
