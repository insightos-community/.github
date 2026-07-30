# Getting Started

[English](../../en/getting-started/quick-start.md)

本指南说明如何在本地构建并启动 **InsightSemantic** 完整环境（单容器 All-in-One），并运行拆码垛仿真示例。

## 环境要求

- Linux **amd64**
- [Docker](https://docs.docker.com/engine/install/) 24+，并启用 Compose 插件（`docker compose version`）
- 建议可用磁盘 ≥ 40GB，内存 ≥ 16GB
- 至少一个 LLM API Key（如 DeepSeek / DashScope / OpenAI 等）

## 1. 进入 Docker 目录

在 InsightOS 仓库根目录：

```bash
cd docker
```

该目录包含：

```text
Dockerfile
docker-compose.yaml
.env.example
```

> 镜像规范名称统一为 **`InsightSemantic`**（例如 `InsightSemantic:1.0.0`）。

## 2. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env`，至少填入一个 LLM Key，并确认镜像名：

```env
RELEASE_IMAGE=InsightSemantic:1.0.0
RELEASE_CONTAINER_NAME=InsightSemantic
FRONTEND_PORT=80

DEEPSEEK_API_KEY=sk-...
# 或其他：DASHSCOPE_API_KEY / OPENAI_API_KEY / ...
```

如需改宿主机端口，可设置 `FRONTEND_PORT=8088`。

## 3. 构建 InsightSemantic 镜像

### 方式 A：使用发布构建工具（推荐，完整环境）

若目录中包含 `scripts/releasectl.sh`（完整发布包 / 开发构建目录），可一键收集依赖并构建：

```bash
./scripts/releasectl.sh build
```

该命令会：

1. 从配套工作区收集二进制、配置、社区拆码垛种子与仿真资产到 `staging/`
2. 以 `staging/` 为构建上下文执行 `docker build`
3. 产出镜像：`InsightSemantic:1.0.0`（以及 `InsightSemantic:latest`，如脚本启用）

### 方式 B：已有 staging 构建上下文时手动构建

`Dockerfile` 的构建上下文必须是 **已准备好的 staging 目录**（含 `bin/`、`configs/`、`runtime/`、`mujoco/` 等），不能只用空的 `docker/` 目录：

```bash
docker build \
  --platform linux/amd64 \
  -f Dockerfile \
  --build-arg RELEASE_VERSION=1.0.0 \
  -t InsightSemantic:1.0.0 \
  -t InsightSemantic:latest \
  ./staging
```

### 方式 C：从 Release 离线包加载（无需本地编译）

若已从 GitHub Releases 下载镜像包：

```bash
docker load -i InsightSemantic-1.0.0-linux-amd64.tar
# 或
./scripts/releasectl.sh load dist/InsightSemantic-1.0.0-linux-amd64.tar
```

确认镜像存在：

```bash
docker images | grep InsightSemantic
```

## 4. 启动完整环境

```bash
# 有 releasectl 时
./scripts/releasectl.sh up

# 或直接使用 Compose
docker compose -f docker-compose.yaml up -d
```

首次启动会初始化 MySQL / 种子项目等，通常需要 1–3 分钟。可观察状态：

```bash
docker compose -f docker-compose.yaml ps
./scripts/releasectl.sh doctor   # 若可用
curl http://127.0.0.1/healthz
```

默认入口（仅暴露前端端口）：

| 入口 | 地址 |
|---|---|
| Web / Insight Studio | http://127.0.0.1/ |
| 健康检查 | http://127.0.0.1/healthz |
| Semantic API | http://127.0.0.1/api/v1/health |
| MuJoCo Viewer | http://127.0.0.1/web-viewer/ |

若修改了 `FRONTEND_PORT`，请把上述地址中的端口一并替换。

## 5. 打开 Insight Studio 并运行示例

1. 浏览器打开 http://127.0.0.1/
2. 使用当前 Release Notes 中的初始账户登录（如有）
3. 在项目库打开「拆码垛」社区项目，等待仿真场景载入
4. 查看项目中的 Skill 文档，在对话框输入：

> 把 A 区的货箱搬到 B 区，码放三层。

系统将展示任务理解、规划流程与仿真执行过程。

## 6. 常用运维命令

```bash
# 查看日志
docker compose -f docker-compose.yaml logs -f --tail=200
# 或
./scripts/releasectl.sh logs

# 重启
docker compose -f docker-compose.yaml restart
# 或
./scripts/releasectl.sh restart

# 停止（保留数据卷）
docker compose -f docker-compose.yaml down
# 或
./scripts/releasectl.sh down
```

数据卷名称以 `InsightSemantic-` 为前缀（如 `InsightSemantic-studio-workspace`）。如需彻底清除数据，再执行 `docker volume rm ...`（请谨慎操作）。

## 7. 故障排查

- **`healthz` 长时间失败**：等待 start_period 结束；执行 `./scripts/releasectl.sh doctor` 或查看 `docker compose logs`
- **对话无响应**：确认 `.env` 中至少一个 LLM API Key 有效
- **端口被占用**：修改 `FRONTEND_PORT` 后重新 `up`
- **镜像名不一致**：确保 `.env` 中 `RELEASE_IMAGE=InsightSemantic:1.0.0`，与 `docker images` 中的标签一致

下一步可阅读[用户手册](../user-guide/insight-studio-and-projects.md)或查看[Reference / FAQ](../reference/faq.md)。
