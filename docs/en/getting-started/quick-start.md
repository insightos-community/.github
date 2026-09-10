# Quick Start

[简体中文](../../zh-CN/getting-started/quick-start.md)

### 1. Install the binary package

On **Linux x86_64**, prepare Bash, curl, and Python 3.10+, then run:

```bash
curl -fsSL https://semantic.insightos.cn/install-en.sh | bash -s -- --install-system-deps
```

The installer prepares Server, Studio, native MuJoCo, the R1 Pro Robot Bundle, scene assets, and the navigation, grasp, and placement skills. It installs to `$HOME/.local/share/semantic` and starts the services. `--install-system-deps` enables installation of the required system libraries through the host's package manager.

### 2. Open Studio

Open **http://localhost:3000** and sign in as **`admin`** using the generated password shown by the installer. To display the login details again and check service status:

```bash
export SEMANTIC_HOME="$HOME/.local/share/semantic"
export PATH="$SEMANTIC_HOME/bin:$PATH"
semanticctl welcome
semanticctl status
```

From another device on the same network, open `http://<server-ip>:3000`. The web gateway listens on `0.0.0.0:3000` by default. Use `semanticctl stop` and `semanticctl start` to stop and start the installation's services.

In Studio's **System Settings**, configure a model with tool-calling support, then create a project and start a scene. Follow [Your first Project](https://github.com/insightos-community/semantic-docs/blob/main/docs/user/getting-started/first-project.md) to run a robot task.

### Detailed installation guides

Continue with **[Quick Start (English)](https://github.com/insightos-community/quick-start/blob/main/README.md)** for the installation documentation and source build workflow. Custom directories and ports, service management, and other binary installation options are covered in the **[binary installer reference (Chinese)](https://github.com/insightos-community/quick-start/blob/main/artifacts/README.md)**. Compatible component revisions are recorded in the [version manifest](https://github.com/insightos-community/quick-start/blob/main/repo-versions.json).
