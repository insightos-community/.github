# Getting Started

[简体中文](../../zh-CN/getting-started/quick-start.md)

This guide shows how to build and start the full **InsightSemantic** all-in-one environment locally, then run the depalletizing simulation example.

## Requirements

- Linux **amd64**
- [Docker](https://docs.docker.com/engine/install/) 24+ with the Compose plugin (`docker compose version`)
- Recommended: ≥ 40GB free disk, ≥ 16GB RAM
- At least one LLM API key (DeepSeek / DashScope / OpenAI / …)

## 1. Enter the Docker directory

From the InsightOS repository root:

```bash
cd docker
```

You should see:

```text
Dockerfile
docker-compose.yaml
.env.example
```

> The canonical image name is **`InsightSemantic`** (for example `InsightSemantic:1.0.0`).

## 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env`, set at least one LLM key, and confirm the image name:

```env
RELEASE_IMAGE=InsightSemantic:1.0.0
RELEASE_CONTAINER_NAME=InsightSemantic
FRONTEND_PORT=80

DEEPSEEK_API_KEY=sk-...
# or: DASHSCOPE_API_KEY / OPENAI_API_KEY / ...
```

To change the host port, set `FRONTEND_PORT=8088`.

## 3. Build the InsightSemantic image

### Option A: Release build tooling (recommended, full stack)

If `scripts/releasectl.sh` is present (full release kit / developer build tree), run:

```bash
./scripts/releasectl.sh build
```

This will:

1. Collect binaries, configs, the community depalletizing seed, and simulation assets into `staging/`
2. Run `docker build` with `staging/` as the build context
3. Produce `InsightSemantic:1.0.0` (and `InsightSemantic:latest` when enabled by the script)

### Option B: Manual build with an existing staging context

The `Dockerfile` **requires a prepared staging directory** as build context (`bin/`, `configs/`, `runtime/`, `mujoco/`, …). Building against an empty `docker/` folder will fail:

```bash
docker build \
  --platform linux/amd64 \
  -f Dockerfile \
  --build-arg RELEASE_VERSION=1.0.0 \
  -t InsightSemantic:1.0.0 \
  -t InsightSemantic:latest \
  ./staging
```

### Option C: Load an offline Release package (no local compile)

If you downloaded an image archive from GitHub Releases:

```bash
docker load -i InsightSemantic-1.0.0-linux-amd64.tar
# or
./scripts/releasectl.sh load dist/InsightSemantic-1.0.0-linux-amd64.tar
```

Verify:

```bash
docker images | grep InsightSemantic
```

## 4. Start the full environment

```bash
# with releasectl
./scripts/releasectl.sh up

# or Compose directly
docker compose -f docker-compose.yaml up -d
```

First boot initializes MySQL and seeds the community project; allow 1–3 minutes. Check status:

```bash
docker compose -f docker-compose.yaml ps
./scripts/releasectl.sh doctor   # if available
curl http://127.0.0.1/healthz
```

Default endpoints (frontend port only):

| Entry | URL |
|---|---|
| Web / Insight Studio | http://127.0.0.1/ |
| Health | http://127.0.0.1/healthz |
| Semantic API | http://127.0.0.1/api/v1/health |
| MuJoCo Viewer | http://127.0.0.1/web-viewer/ |

If you changed `FRONTEND_PORT`, replace the port in the URLs above.

## 5. Open Insight Studio and run the example

1. Open http://127.0.0.1/ in a browser
2. Sign in with the initial account from the current Release Notes (if provided)
3. Open the Depalletizing community project and wait for the simulation scene to load
4. Read the project Skill docs, then enter:

> Move the boxes from Area A to Area B and stack them in three layers.

Insight Studio shows goal understanding, task planning, and simulation execution.

## 6. Common operations

```bash
# Logs
docker compose -f docker-compose.yaml logs -f --tail=200
# or
./scripts/releasectl.sh logs

# Restart
docker compose -f docker-compose.yaml restart
# or
./scripts/releasectl.sh restart

# Stop (keeps volumes)
docker compose -f docker-compose.yaml down
# or
./scripts/releasectl.sh down
```

Volumes are prefixed with `InsightSemantic-` (for example `InsightSemantic-studio-workspace`). Remove volumes only if you intentionally want a clean slate.

## 7. Troubleshooting

- **`healthz` fails for a long time:** wait for the healthcheck start period; run `./scripts/releasectl.sh doctor` or inspect `docker compose logs`
- **Chat does not respond:** confirm at least one LLM API key in `.env` is valid
- **Port already in use:** change `FRONTEND_PORT` and `up` again
- **Image name mismatch:** ensure `.env` has `RELEASE_IMAGE=InsightSemantic:1.0.0` and that tag appears in `docker images`

Next, read the [User Guide](../user-guide/insight-studio-and-projects.md) or see the [Reference / FAQ](../reference/faq.md).
