# Semantic Studio and Projects

[简体中文](../../zh-CN/user-guide/insight-studio-and-projects.md)

Semantic Studio is the semantic application development and interaction entry point for InsightOS Semantic. Use it to manage projects, compose Skills, run tasks, and view simulation.

## Project Library

After installation, configure a model with tool-calling support in System Settings, create a project, and start a scene. The installer includes the R1 Pro Robot Bundle, scene assets, and navigation, grasp, and placement skills. Follow [Your first Project](https://github.com/insightos-community/semantic-docs/blob/main/docs/user/getting-started/first-project.md) for the task operation flow.

## Project Contents

A project typically contains:

- A scene and semantic world model.
- Task goals and example prompts.
- Skill documents and workflows.
- Robot, Ability, and runtime configuration.
- Simulation assets and project resources.

## Conversational Task Creation

Users describe goals in natural language. Semantic Studio turns each request into a task goal and workflow, then displays the required Skills, robot assignments, and execution progress.

## Simulation

When a project opens, Semantic Studio can load its simulation scene. Users can inspect robots, objects, semantic environment state, and task execution.

## Skill Documents

Skill documents in the project describe available capabilities, inputs, outputs, and applicable tasks. Developers can create new Skills with the SDK and install them into projects.
