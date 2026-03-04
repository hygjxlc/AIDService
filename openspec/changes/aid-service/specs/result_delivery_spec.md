# Result Delivery Module Specification

## Overview
接收算法层的仿真结果与优化模具文件，为SDK提供结果获取接口，支持仿真完成后的模具文件下载。

## Added Requirements

### REQ-RD-001: Task Result Fetch (fetachTaskResult)
**SHALL** provide API to fetch optimized mold file for finished tasks.

**Scenarios:**
- SC-065: 任务状态为finished，成功返回优化模具文件
- SC-066: 任务状态非finished，返回404错误
- SC-067: 模具文件不存在，返回404错误
- SC-068: TaskID不存在，返回404错误

**Acceptance Criteria:**
- 仅状态为finished的任务可获取结果
- 返回*.stp格式的优化后模具文件
- 文件以文件流形式返回
- 非finished状态返回code=404
- 文件不存在返回code=404

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| TaskID | string | 是 | 状态为finished |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功，404失败 |
| message | string | 响应描述 |
| taskID | string | 任务ID |
| file | file_stream | 优化后模具文件 |

### REQ-RD-002: Result File Validation
**SHALL** validate result file existence before delivery.

**Scenarios:**
- SC-069: 算法层生成结果文件后，验证文件存在
- SC-070: 结果文件损坏或缺失，返回错误

**Acceptance Criteria:**
- 获取前验证服务器中结果文件存在
- 验证文件完整性
- 文件不存在或损坏时返回明确错误信息

### REQ-RD-003: Result File Format
**SHALL** ensure result file is in STP format.

**Scenarios:**
- SC-071: 返回的文件格式为.stp
- SC-072: 文件名包含任务标识

**Acceptance Criteria:**
- 结果文件格式为*.stp
- 文件名示例：mould_optimize.stp 或 {TaskID}_optimized.stp
- 文件可被CAD软件正常打开

### REQ-RD-004: Algorithm Layer Result Reception
**SHALL** receive and store result files from algorithm layer.

**Scenarios:**
- SC-073: 算法层计算完成，接收结果文件
- SC-074: 结果文件存储到任务目录

**Acceptance Criteria:**
- 算法层完成后自动接收结果文件
- 结果文件存储路径：/data/aid/{TaskID}/result/
- 更新任务状态为finished
- 记录结果文件路径到数据库
