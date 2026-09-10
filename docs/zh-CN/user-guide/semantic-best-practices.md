# insightOS Semantic 最佳实践指南

> 本文记录旧版拆码垛示例的界面与项目配置。当前 Studio 操作流程请参阅[第一个 Project](https://github.com/insightos-community/semantic-docs/blob/main/docs/user/getting-started/first-project.md)，安装请参阅[快速开始](../getting-started/quick-start.md)。

[English](../../en/user-guide/semantic-best-practices.md)

从场景启动到工作流验证的标准操作步骤。

![insightOS Semantic 标准操作流程图：进入项目、启动仿真、配置场景、生成计划、运行验证](../../images/semantic-best-practices/flow-overview.png)

> **使用提醒：** 开始操作前，请先将 Agent 切换为 `leader-Leader-team`，并确保已进入“拆码垛项目”。

适用范围：insightOS Semantic 拆码垛项目的首次执行、场景个性化调整及追加搬运任务。

## 开始前准备

完成以下检查后，再按本指南执行主流程。

| 检查项 | 确认内容 |
| --- | --- |
| **项目** | 从社区进入“拆码垛项目”，在项目页确认计划步骤。 |
| **Agent** | 切换至 `leader-Leader-team`，使后续提示和计划生成使用正确的执行角色。 |
| **场景** | 确认项目已绑定仿真场景，并在启动后可以看到机器人、箱子和目标区域。 |

**图 1 项目页中的计划步骤**

![项目页中的计划步骤](../../images/semantic-best-practices/project-plan-steps.png)

从项目入口进入后，先确认当前任务的计划步骤与执行入口。

## 步骤 1：了解项目并启动仿真场景

**目的：** 打开项目绑定的仿真场景，建立当前操作对象和环境的整体认知。

- 在拆码垛项目中查看当前场景。
- 启动项目绑定的仿真场景，等待场景完全加载。

**图 2 仿真场景已启动**

![仿真场景已启动](../../images/semantic-best-practices/scene-started.png)

场景中应能看到码垛箱体、机器人设备和目标区域。

## 步骤 2：按提示修改仿真场景

**目的：** 依据 Agent 的提示识别并调整目标对象，让仿真配置符合当前任务要求。

- 需要修改箱子时，先在语义地图中确认箱子的具体名称。
- 按 Agent 提示进行个性化调整；示例仅修改了一个箱子的颜色。

### 2.1 在语义地图中确认对象名称

选择目标箱子后，在右侧信息区读取名称。后续指令请使用该名称，避免引用到错误对象。

**图 3 选择目标箱子并查看名称**

![选择目标箱子并查看名称](../../images/semantic-best-practices/select-box-name.png)

语义地图用于定位对象、确认名称，并识别目标区域。

### 2.2 根据 Agent 提示完成修改

**图 4 按提示提交场景修改**

![按提示提交场景修改](../../images/semantic-best-practices/submit-scene-change.png)

在对话或配置区域输入明确的修改要求。

**图 5 修改后的场景状态**

![修改后的场景状态](../../images/semantic-best-practices/scene-modified.png)

示例中目标箱体颜色已发生变化，说明个性化配置已生效。

## 步骤 3：选择运行的 Agent 机器人设备

**目的：** 为任务指定正确的机器人设备，使工作流能够关联可执行的资源。

- 根据 Agent 提示选择机器人设备。
- 确认设备选择结果后再进入计划创建，避免后续重新生成流程。

**图 6 选择 Agent 机器人设备**

![选择 Agent 机器人设备](../../images/semantic-best-practices/select-robot-device.png)

在设备选择区勾选或确认建议的机器人设备。

## 步骤 4：创建工作流计划

**目的：** 根据用户输入明确搬运对象和目标位置，由系统生成可执行的工作流计划。

- 在输入中同时说明搬运对象和目标区域。
- 使用在语义地图中确认过的箱子名称，确保对象指向准确。

**图 7 输入搬运任务并创建计划**

![输入搬运任务并创建计划](../../images/semantic-best-practices/create-workflow-plan.png)

任务描述应包含“搬运什么”和“搬到哪里”两个关键信息。

## 步骤 5：运行工作流并验证结果

**目的：** 执行系统生成的工作流，核对 Agent 返回信息与仿真实际效果。

- 运行已生成的工作流。
- 查看工作流节点、Agent 返回信息和仿真画面，确认搬运结果符合预期。

**图 8 系统自动生成的工作流程**

![系统自动生成的工作流程](../../images/semantic-best-practices/generated-workflow.png)

生成后可在工作流视图中核对任务节点与执行链路。

**图 9 首次搬运完成后的仿真效果**

![首次搬运完成后的仿真效果](../../images/semantic-best-practices/first-move-result.png)

结束时应同时检查 Agent 返回内容与场景中的实际搬运结果。

> **验收要点：** 确认目标箱体已进入指定区域，且工作流没有报错或停留在未完成状态。

## 追加搬运任务

首次任务完成后，可以在同一对话中继续补充搬运需求。系统会依据新输入生成对应的后续工作流。

> **示例指令：** 把 `box-a14`、`box-a24`、`box-a44` 也搬到目标位置。

**图 10 输入追加搬运指令**

![输入追加搬运指令](../../images/semantic-best-practices/additional-task-command.png)

使用已确认的对象名称逐一列出需要追加搬运的箱子。

**图 11 Agent 执行追加搬运任务**

![Agent 执行追加搬运任务](../../images/semantic-best-practices/additional-task-execution.png)

Agent 会根据新的需求依次处理指定箱子。

**图 12 追加搬运后的场景效果**

![追加搬运后的场景效果](../../images/semantic-best-practices/additional-move-result.png)

再次核对箱体位置和目标区域状态。

**图 13 第二次搬运对应的工作流**

![第二次搬运对应的工作流](../../images/semantic-best-practices/second-workflow.png)

每次追加任务都会生成对应工作流，可据此追踪执行过程。

## 快速检查清单

- 已进入“拆码垛项目”，并确认计划步骤。
- Agent 已切换为 `leader-Leader-team`。
- 已启动项目绑定的仿真场景。
- 已在语义地图中确认目标箱子名称。
- 已选择正确的 Agent 机器人设备。
- 输入内容同时包含搬运对象和目标位置。
- 工作流运行完成，且 Agent 返回与仿真效果一致。

> **排障建议：** 若计划未按预期生成，请优先检查 Agent 角色、设备选择、对象名称和目标位置描述是否完整。
