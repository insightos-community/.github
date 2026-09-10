# 快速开始

[English](../../en/getting-started/quick-start.md)

### 1. 二进制安装

在 **Linux x86_64** 机器上准备 Bash、curl 和 Python 3.10+，执行：

```bash
curl -fsSL https://semantic.insightos.cn/install.sh | bash -s -- --install-system-deps
```

安装器会准备 Server、Studio、原生 MuJoCo、R1 Pro Robot Bundle、场景资产，以及导航、抓取和放置技能，默认安装到 `$HOME/.local/share/semantic` 并启动服务。`--install-system-deps` 表示通过宿主机的包管理器安装所需系统库。

### 2. 打开 Studio

打开 **http://localhost:3000**，使用 **`admin`** 和安装器显示的随机密码登录。以下命令可以重新查看登录信息与服务状态：

```bash
export SEMANTIC_HOME="$HOME/.local/share/semantic"
export PATH="$SEMANTIC_HOME/bin:$PATH"
semanticctl welcome
semanticctl status
```

从同一网络中的另一台设备访问时，使用 `http://<服务器 IP>:3000`。Web 网关默认监听 `0.0.0.0:3000`。日常启停服务使用 `semanticctl stop` 和 `semanticctl start`。

在 Studio 的**系统设置**中配置支持工具调用的模型，再创建项目并启动场景，即可按[第一个 Project](https://github.com/insightos-community/semantic-docs/blob/main/docs/user/getting-started/first-project.md)运行机器人任务。

### 详细安装指南

完整安装文档与源码构建流程见 **[Quick Start 中文指南](https://github.com/insightos-community/quick-start/blob/main/README.zh-CN.md)**。自定义目录和端口、服务管理及其他二进制安装选项见 **[二进制安装说明](https://github.com/insightos-community/quick-start/blob/main/artifacts/README.md)**，各组件的配套版本见[版本清单](https://github.com/insightos-community/quick-start/blob/main/repo-versions.json)。
