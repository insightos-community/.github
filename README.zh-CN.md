# InsightOS Semantic

[English](./README.md) · [快速开始](./docs/zh-CN/getting-started/quick-start.md) · [安装指南](./docs/zh-CN/getting-started/installation.md) · [用户手册](./docs/zh-CN/user-guide/insight-studio-and-projects.md) · [最佳实践](./docs/zh-CN/user-guide/semantic-best-practices.md) · [FAQ](./docs/zh-CN/reference/faq.md)

> 让每一种机器人都能真正干活。

InsightOS Semantic 是具识智能面向具身场景打造的语义智能体系统。它以语义连接机器人本体、环境、任务、Skill 和运行经验，将自然语言需求转化为机器人可以执行的任务，并贯通**理解—规划—执行—进化**的完整闭环。

InsightOS Semantic 支持售货仓取货配送、拆码垛搬运、多机协同流水线、定时巡检等场景，可连接人形机器人、四足机器人、机械臂和移动机器人等多种本体。

## 为什么需要 InsightOS Semantic

机器人从“能演示”走向“能干活”，通常面临三类问题：

- **不能理解**：任务依赖固定代码，难以理解人的意图和场景约束。
- **不懂变通**：环境、物体或执行状态发生变化时，固定流程难以继续。
- **不会进化**：执行经验难以沉淀，换本体、换场景后往往需要重新开发。

InsightOS Semantic 使用统一语义连接任务、环境、本体和能力，让机器人可以理解目标、组织 Skill、执行任务，并将运行经验沉淀为可复用能力。

## 产品架构

![InsightOS Semantic 系统架构](./assets/insightos-semantic-architecture.png)

### Insight Studio

通过自然语言创建和管理具身项目，将需求转化为任务目标、Workflow 和 Skill，并连接语义世界模型与仿真环境。

### Insight Ops

关注任务运行过程中的环境变化、异常诊断、恢复和续跑，让机器人能够适应动态场景。

### Insight Framework & Kernel

提供语义任务编排、机器人与资源管理、能力发现与调用、世界状态同步，以及运行经验沉淀。

## 核心 Features

- **自然语言任务交互**：通过一句话描述目标，由系统组织任务和 Skill。
- **多机器人协同**：面向异构机器人分配任务并协调工作流程。
- **语义世界模型**：同时表达物体是什么、位于哪里以及彼此关系。
- **动态环境适应**：根据环境和执行状态变化调整任务过程。
- **仿真驱动开发**：连接场景、机器人、Skill 和任务，在仿真中快速验证。
- **经验与能力进化**：将执行数据和经验沉淀为可复用、可持续优化的 Skill。
- **具身应用生态**：复用场景应用、Skill、模型、插件、适配器和仿真资产。

## 快速体验

Public Preview 将通过 GitHub Releases 提供安装包和拆码垛示例资产。基本体验流程如下：

1. 下载并安装 InsightOS Semantic Public Preview。
2. 将拆码垛素材包放到安装说明指定的目录。
3. 在本地浏览器打开 Insight Studio。
4. 从项目库打开“拆码垛”项目并启动仿真。
5. 查看项目中的 Skill 文档。
6. 输入“把 A 区的货箱搬到 B 区，码放三层”，观察任务规划和仿真执行。

完整步骤见[快速开始](./docs/zh-CN/getting-started/quick-start.md)。

基于 Docker 的安装与启动见[安装指南](./docs/zh-CN/getting-started/installation.md)；拆码垛操作流程见 [insightOS Semantic 最佳实践](./docs/zh-CN/user-guide/semantic-best-practices.md)。

## 演示视频

- [insightOS Semantic 语义框架拆码垛实例（哔哩哔哩）](https://b23.tv/xKIMMtE)
- [insightOS Semantic 语义框架拆码垛最佳实践（哔哩哔哩）](https://b23.tv/07bVBQT)

## 开源与分发方式

InsightOS 采用分阶段开源方式：Public Preview 首先提供完整试用所需的二进制组件、示例包和部分组件源码，随后逐步开放更多模块和新 Features。

| 模块 | 当前计划 |
|---|---|
| InsightOS 主仓 | 产品入口、文档和 GitHub Releases |
| 能力框架 | 独立仓库，源码开放 |
| Ability SDK | 独立仓库，源码开放 |
| Insight Framework| 独立仓库，预览二进制，后续逐步开放源码 |
| Insight Studio & Ops| 独立仓库，预览二进制，后续逐步开放源码 |
| Semantic Map | 独立仓库，预览二进制，后续逐步开放源码 |
| 仿真引擎与仿真资产 | 软件包分发；资产采用独立许可 |
| 能力实例与场景应用 | 示例包分发，逐步增加开放内容 |

## Feature Roadmap

| 阶段 | Feature 主题 |
|---|---|
| **2026 Q3：系统基础与 Public Preview** | 语义系统基础、仿真资源模型、Ability/Skill 体系、语义世界模型、本地试用与基础示例 |
| **2026 Q4：开发能力** | 流程开发、Skill 开发、仿真场景开发，以及面向开发者的 SDK 和工具链 |
| **2027 Q1：高级智能** | 经验进化、Skill 持续优化、异常感知与处理、任务恢复和动态环境适应 |
| **2027 Q2：开放生态** | 场景应用、Skill、模型、插件和仿真资源生态，软件包分发与第三方开发者共建 |

## 文档

- [Getting Started](./docs/zh-CN/getting-started/quick-start.md)
- [安装指南](./docs/zh-CN/getting-started/installation.md)
- [用户手册](./docs/zh-CN/user-guide/insight-studio-and-projects.md)
- [insightOS Semantic 最佳实践](./docs/zh-CN/user-guide/semantic-best-practices.md)
- [Reference / FAQ](./docs/zh-CN/reference/faq.md)

## 参与贡献

欢迎通过 Issue 提交问题和建议，或通过 Pull Request 改进已经开放的源码与文档。参见[贡献指南](./CONTRIBUTING.zh-CN.md)。

## License

本仓库公开的源码采用 [Apache License 2.0](./LICENSE)（`Apache-2.0`）。预览二进制、模型和仿真资产可能使用各自随包提供的许可证。

