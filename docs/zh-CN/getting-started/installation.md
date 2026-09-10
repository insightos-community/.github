# 安装指南

[English](../../en/getting-started/installation.md)

按照[本地快速开始](quick-start.md)使用二进制安装器。安装器在 Linux x86_64 上准备 Server、Studio、原生 MuJoCo、R1 Pro Robot Bundle、场景资产，以及导航、抓取和放置技能。

默认安装目录为 `$HOME/.local/share/semantic`。打开 http://localhost:3000，使用 `admin` 和安装器显示的随机密码登录。使用 `semanticctl welcome` 查看登录信息，`semanticctl status` 检查服务，`semanticctl stop` / `semanticctl start` 管理服务启停。

## 安装参考

- [Quick Start 中文指南](https://github.com/insightos-community/quick-start/blob/main/README.zh-CN.md)：完整安装与源码构建流程。
- [二进制安装说明](https://github.com/insightos-community/quick-start/blob/main/artifacts/README.md)：自定义目录、端口、服务管理与安装选项。
- [组件版本清单](https://github.com/insightos-community/quick-start/blob/main/repo-versions.json)：各组件的配套版本。

原 Docker／Harbor 安装说明已由此安装流程替换。`docker/` 目录保留旧版发布工具；当前安装与打包流程在 quick-start 仓库维护。
