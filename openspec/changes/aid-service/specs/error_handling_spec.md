# Error Handling Module Specification

## Overview
统一管理AID-service端的所有错误码，定义错误码的含义、适用场景，实现标准化的错误信息返回。

## Added Requirements

### REQ-EH-001: Global Error Code System
**SHALL** implement unified error code system for all APIs.

**Error Code Definitions:**
| 类型 | 码值 | 含义 | 适用场景 |
|-----|------|------|---------|
| 成功 | 200 | 操作成功 | 所有接口正常执行 |
| 业务 | 301 | 任务创建失败 | newTaskCreate |
| 业务 | 302 | 工作文件缺失 | newTaskverify |
| 业务 | 303 | 上传文件失败 | uploadParamfiles |
| 业务 | 401 | 任务开始失败/未授权 | startTask/所有接口认证失败 |
| 业务 | 402 | 任务停止失败 | stopTask |
| 业务 | 403 | 任务删除失败 | deleteTask |
| 业务 | 404 | 获取结果失败 | queryTaskStatus/fetachTaskResult |
| 系统 | 500 | 算法内部运行错误 | 所有接口算法层异常 |

**Scenarios:**
- SC-095: 所有接口使用统一错误码
- SC-096: 不允许自定义独立错误码
- SC-097: 错误码含义唯一无歧义

### REQ-EH-002: Error Response Format
**SHALL** return standardized error response structure.

**Response Structure:**
| 字段 | 类型 | 必填 | 说明 |
|-----|------|-----|------|
| code | int | 是 | 错误码 |
| message | string | 是 | 错误描述（中文） |
| taskID | string | 否 | 关联任务ID |

**Scenarios:**
- SC-098: 所有错误响应包含code和message
- SC-099: 有TaskID时包含taskID字段
- SC-100: message为中文清晰描述

**Acceptance Criteria:**
- 所有错误响应遵循统一结构
- message字段为中文描述
- 包含具体失败原因，避免模糊表述

### REQ-EH-003: Detailed Error Messages
**SHALL** provide detailed and specific error messages.

**Scenarios:**
- SC-101: 参数校验失败，返回具体参数错误原因
- SC-102: 文件上传失败，返回具体文件失败原因
- SC-103: 算法层错误，返回算法层原始错误信息

**Acceptance Criteria:**
- message包含具体失败原因
- 示例："任务创建失败，仿真类型编码不合法，仅支持LaWan/CHOnYA等编码"
- 算法内部运行错误(500)包含算法层原始错误信息
- 同一错误码在不同场景下message差异化

### REQ-EH-004: Error Logging
**SHALL** log all errors to error_log table and log files.

**Scenarios:**
- SC-104: 错误发生时记录到error_log表
- SC-105: 错误发生时写入错误日志文件
- SC-106: 错误日志包含完整堆栈信息

**Acceptance Criteria:**
- 所有错误记录到SQLite error_log表
- 错误日志文件按日滚动
- 记录字段：task_id, error_code, error_message, error_time, interface_name
- 包含完整错误堆栈便于问题定位

### REQ-EH-005: Algorithm Layer Error Handling
**SHALL** handle and propagate algorithm layer errors appropriately.

**Scenarios:**
- SC-107: 算法层返回错误时，状态更新为failed
- SC-108: 算法层连接超时，返回500错误
- SC-109: 算法层异常时，记录原始错误信息

**Acceptance Criteria:**
- 算法层错误统一使用code=500
- message包含算法层原始错误描述
- 任务状态自动更新为failed
- 完整记录算法层错误日志

### REQ-EH-006: Input Validation Errors
**SHALL** provide specific error messages for input validation failures.

**Scenarios:**
- SC-110: simulateType不合法，返回具体允许的值
- SC-111: taskName格式不合法，返回格式要求
- SC-112: 文件格式不合法，返回允许的格式列表

**Acceptance Criteria:**
- 参数校验失败返回具体约束要求
- 示例：
  - "simulateType不合法，仅支持：LaWan/CHOnYA/ZhuZao/ZhaZhi/ZHEWan/JIYA"
  - "taskName长度必须为1-64字符，仅支持字母/数字/下划线"
  - "文件格式不合法，仅支持：stp/txt/csv/yml/jnl"
