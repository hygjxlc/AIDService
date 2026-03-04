# Task Management Module Specification

## Overview
实现仿真任务的创建、校验、启动、停止、删除核心能力，管理仿真任务的完整生命周期。

## Added Requirements

### REQ-TM-001: Task Creation (newTaskCreate)
**SHALL** provide API to create new simulation tasks and generate unique TaskID.

**Scenarios:**
- SC-012: 使用合法simulateType和taskName创建任务，返回TaskID
- SC-013: 使用非法simulateType创建任务，返回301错误
- SC-014: 使用空taskName创建任务，返回301错误
- SC-015: 使用超长taskName(>64字符)创建任务，返回301错误

**Acceptance Criteria:**
- simulateType必须为：LaWan/CHOnYA/ZhuZao/ZhaZhi/ZHEWan/JIYA
- taskName长度1-64位，支持字母/数字/下划线
- TaskID生成规则：simulateType编码 + 8位自增数字
- 成功返回code=200，taskID为生成的任务ID
- 失败返回code=301，message包含具体失败原因

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| simulateType | string | 是 | LaWan/CHOnYA/ZhuZao/ZhaZhi/ZHEWan/JIYA |
| taskName | string | 是 | 1-64字符，字母/数字/下划线 |
| api_key | string | 是 | 必须为11111111 |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功，301失败 |
| message | string | 响应描述 |
| taskID | string | 任务ID，失败为null |

### REQ-TM-002: Task Verification (newTaskverify)
**SHALL** provide API to verify parameter file completeness for a task.

**Scenarios:**
- SC-016: 所有必选文件已上传，返回ready=true
- SC-017: 部分必选文件未上传，返回ready=false和missingFiles列表
- SC-018: TaskID不存在，返回404错误

**Acceptance Criteria:**
- 校验7个必选文件是否全部上传
- ready=true表示任务就绪可启动
- ready=false时返回遗留必选文件名称列表
- TaskID不存在返回code=404

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| TaskID | string | 是 | 符合TaskID生成规则 |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功，302文件缺失，404任务不存在 |
| message | string | 响应描述 |
| taskID | string | 任务ID |
| ready | bool | 就绪状态 |
| missingFiles | array | 遗留必选文件列表 |

### REQ-TM-003: Task Start (startTask)
**SHALL** provide API to start simulation task execution.

**Scenarios:**
- SC-019: 任务状态为created，必选文件完整，成功启动任务
- SC-020: 任务状态为stop，必选文件完整，成功重新启动任务
- SC-021: 任务状态为running，返回401错误
- SC-022: 必选文件未完全上传，返回401错误
- SC-023: TaskID不存在，返回404错误

**Acceptance Criteria:**
- 仅状态为created/stop的任务可启动
- 启动前自动校验必选文件完整性
- 调用算法层开始仿真计算
- 启动成功后状态更新为running
- 成功返回code=200，status=running

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| TaskID | string | 是 | 状态为created/stop |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功，401失败，404任务不存在 |
| message | string | 响应描述 |
| taskID | string | 任务ID |
| status | string | 任务状态 |

### REQ-TM-004: Task Stop (stopTask)
**SHALL** provide API to stop running simulation tasks.

**Scenarios:**
- SC-024: 任务状态为running，成功停止任务
- SC-025: 任务状态非running，返回"操作无效"
- SC-026: TaskID不存在，返回404错误

**Acceptance Criteria:**
- 仅状态为running的任务可停止
- 停止后保留所有参数文件
- 停止成功后状态更新为stop
- 状态非running时返回code=200，message="操作无效"
- 算法层调用失败返回code=402

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| TaskID | string | 是 | 符合TaskID生成规则 |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功/操作无效，402失败，404任务不存在 |
| message | string | 响应描述 |
| taskID | string | 任务ID |
| status | string | 任务状态 |

### REQ-TM-005: Task Delete (deleteTask)
**SHALL** provide API to delete simulation tasks in any status.

**Scenarios:**
- SC-027: 删除created状态的任务
- SC-028: 删除running状态的任务（先停止再删除）
- SC-029: 删除finished状态的任务及结果文件
- SC-030: TaskID不存在，返回404错误

**Acceptance Criteria:**
- 支持删除任意状态的任务
- running状态任务先执行停止操作
- 删除所有参数文件和结果文件
- 从SQLite中删除所有相关数据
- 释放所有占用资源
- 成功返回code=200

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| TaskID | string | 是 | 符合TaskID生成规则 |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功，403失败，404任务不存在 |
| message | string | 响应描述 |
| taskID | string | 任务ID |
