# Semantic Studio 和项目

[English](../../en/user-guide/insight-studio-and-projects.md)

Semantic Studio 是 InsightOS Semantic 的语义应用开发与交互入口，用于管理项目、编排 Skill、运行任务和查看仿真。

## 项目库

安装后，先在系统设置中配置支持工具调用的模型，再创建项目并启动场景。安装器包含 R1 Pro Robot Bundle、场景资产，以及导航、抓取和放置技能。任务操作流程见[第一个 Project](https://github.com/insightos-community/semantic-docs/blob/main/docs/user/getting-started/first-project.md)。

## 项目内容

一个项目通常包含：

- 场景和语义世界模型。
- 任务目标和示例 Prompt。
- Skill 文档与 Workflow。
- 机器人、Ability 和 Runtime 配置。
- 仿真资产与项目资源。

## 对话式任务构建

用户可以使用自然语言描述目标。Semantic Studio 将需求转化为任务目标和 Workflow，并展示所需的 Skill、机器人分工和执行进度。

## 仿真

打开项目后，Semantic Studio 可以加载对应仿真场景。用户可查看机器人、物体、语义环境状态以及任务执行过程。

## Skill 文档

项目目录中的 Skill 文档描述该项目可使用的能力、输入输出和适用任务。开发者可以通过 SDK 创建新的 Skill，并将其安装到项目中。
