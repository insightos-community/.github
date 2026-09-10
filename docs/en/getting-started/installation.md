# Installation

[简体中文](../../zh-CN/getting-started/installation.md)

Use the binary installer described in the [local Quick Start](quick-start.md). It prepares Server, Studio, native MuJoCo, the R1 Pro Robot Bundle, scene assets, and navigation, grasp, and placement skills on Linux x86_64.

The default installation directory is `$HOME/.local/share/semantic`. Open http://localhost:3000 and sign in as `admin` with the generated password displayed by the installer. Use `semanticctl welcome` to display the login details, `semanticctl status` to inspect services, and `semanticctl stop` / `semanticctl start` to manage them.

## Installation references

- [Quick Start (English)](https://github.com/insightos-community/quick-start/blob/main/README.md): complete installation and source builds.
- [Binary installer reference (Chinese)](https://github.com/insightos-community/quick-start/blob/main/artifacts/README.md): custom directories, ports, service management, and installer options.
- [Component version manifest](https://github.com/insightos-community/quick-start/blob/main/repo-versions.json): compatible component revisions.

The previous Docker/Harbor installation instructions have been superseded by this installer workflow. The `docker/` directory contains legacy release tooling; current installation and packaging are maintained in the quick-start repository.
