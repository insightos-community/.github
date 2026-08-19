# InsightSemantic 安装与启动指南

[English](../../en/getting-started/installation.md)

**运行前提：** 目标机器需预先安装 Docker（含 Docker Compose）。安装与启动仅需使用 `run-insightsemantic.sh` 脚本。

## 标准安装流程

**核心原则：** 环境准备完成后，只需执行 `run-insightsemantic.sh` 脚本。镜像登录、拉取、配置生成和服务启动均由脚本自动处理。

| 准备环境 | 放置脚本 | 执行脚本 | 访问服务 |
| --- | --- | --- | --- |
| Docker + Compose | 运行目录 | 唯一启动动作 | 浏览器验证 |

**唯一执行命令：** 根据是否已登录 Harbor、是否需要拉取镜像或是否已配置 Key，为 `run-insightsemantic.sh` 添加对应参数即可；无需手动执行 Docker 命令。

## 1. 准备运行目录

将 `scripts/run-insightsemantic.sh` 复制到准备运行容器的空目录中。以下以 `~/insightsemantic` 为例：

```bash
mkdir -p ~/insightsemantic
cd ~/insightsemantic
chmod +x run-insightsemantic.sh
```

## 2. 从 Harbor 拉取镜像并启动

首次执行时，使用 Harbor 账号登录并拉取镜像。请将示例账号和密码替换为实际凭据。

```bash
./run-insightsemantic.sh --user <Harbor用户名> --password "<Harbor密码>"
```

脚本会自动完成以下操作：

- 在当前目录生成 `.env` 和 `docker-compose.yaml`。
- 登录 `git.insightos.cn:11016`。
- 拉取 `git.insightos.cn:11016/framework/insightsemantic:1.0.0`。
- 将镜像标记为本地 `insightsemantic:1.0.0`。
- 启动 InsightSemantic 服务。

> 配置文件模板见仓库 [docker/docker-compose.yaml](../../../docker/docker-compose.yaml) 与 [docker/.env.example](../../../docker/.env.example)，生成后可参考模板手动调整配置。

> 已登录 Harbor 时，可使用以下命令。`--pull` 仅在本地不存在 `insightsemantic:1.0.0` 镜像时使用；本地已有相同镜像时无需拉取。

```bash
./run-insightsemantic.sh --skip-login --pull
```

## 3. 配置 LLM Key（按需）

编辑当前目录的 `.env` 文件，至少填写一个模型 Key。`[docker/.env.example](../../../docker/.env.example)` 提供了完整的变量模板。例如：

```bash
DEEPSEEK_API_KEY=<你的Key>
```

配置完成后执行：

```bash
./run-insightsemantic.sh --skip-login
```

> 配置位置：脚本会将当前目录的 `.env` 同步至容器内的 `/opt/jushi/.env`。

## 4. 打开服务并进行健康检查

服务启动后，在浏览器中访问以下地址：

- **Web：** http://127.0.0.1/
- **社区：** http://127.0.0.1/community
- **健康检查：** http://127.0.0.1/healthz

## 5. 停止服务

需要停止运行时，在运行目录执行：

```bash
./run-insightsemantic.sh --down
```
