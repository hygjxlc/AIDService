# Data Storage Module Specification

## Overview
基于SQLite实现AID-service端所有业务数据的持久化存储，提供数据的增、删、改、查能力，确保数据一致性和原子性。

## Added Requirements

### REQ-DS-001: Database Initialization
**SHALL** initialize SQLite database with required tables on startup.

**Scenarios:**
- SC-075: 服务启动时创建所有数据表
- SC-076: 数据库已存在时跳过创建
- SC-077: 数据库文件损坏时报错并退出

**Acceptance Criteria:**
- 自动创建task_info、file_info、error_log三张表
- 表结构符合规格定义
- 数据库文件路径可配置
- 初始化失败时抛出明确异常

### REQ-DS-002: Task Info Table
**SHALL** manage task_info table for task basic information.

**Table Schema:**
| 字段 | 类型 | 主键 | 非空 | 说明 |
|-----|------|-----|-----|------|
| task_id | TEXT | 是 | 是 | 任务唯一标识 |
| simulate_type | TEXT | 否 | 是 | 仿真类型编码 |
| task_name | TEXT | 否 | 是 | 任务名称 |
| status | TEXT | 否 | 是 | 任务状态 |
| create_time | TEXT | 否 | 是 | 创建时间 |
| update_time | TEXT | 否 | 是 | 更新时间 |

**Scenarios:**
- SC-078: 创建任务时插入task_info记录
- SC-079: 状态变更时更新status和update_time
- SC-080: 删除任务时删除task_info记录

### REQ-DS-003: File Info Table
**SHALL** manage file_info table for uploaded file information.

**Table Schema:**
| 字段 | 类型 | 主键 | 非空 | 说明 |
|-----|------|-----|-----|------|
| file_id | INTEGER | 是 | 是 | 文件自增ID |
| task_id | TEXT | 否 | 是 | 关联任务ID |
| file_name | TEXT | 否 | 是 | 文件名 |
| file_path | TEXT | 否 | 是 | 存储路径 |
| file_size | INTEGER | 否 | 是 | 文件大小(字节) |
| upload_time | TEXT | 否 | 是 | 上传时间 |
| file_type | TEXT | 否 | 是 | required/optional |

**Scenarios:**
- SC-081: 上传文件时插入file_info记录
- SC-082: 覆盖文件时更新file_info记录
- SC-083: 删除任务时删除关联的file_info记录

### REQ-DS-004: Error Log Table
**SHALL** manage error_log table for error tracking.

**Table Schema:**
| 字段 | 类型 | 主键 | 非空 | 说明 |
|-----|------|-----|-----|------|
| log_id | INTEGER | 是 | 是 | 日志自增ID |
| task_id | TEXT | 否 | 是 | 关联任务ID |
| error_code | INTEGER | 否 | 是 | 错误码 |
| error_message | TEXT | 否 | 是 | 错误信息 |
| error_time | TEXT | 否 | 是 | 错误时间 |
| interface_name | TEXT | 否 | 是 | 触发接口名 |

**Scenarios:**
- SC-084: 接口返回错误时记录error_log
- SC-085: 按TaskID查询错误日志历史

### REQ-DS-005: Data Atomicity
**SHALL** ensure atomic operations for all database transactions.

**Scenarios:**
- SC-086: 多表操作在事务中完成
- SC-087: 操作失败时全部回滚
- SC-088: 事务提交成功时数据持久化

**Acceptance Criteria:**
- 单个业务流程的多个数据操作作为一个事务
- 事务失败时全部回滚，不留残留数据
- 使用SQLite的事务机制保证原子性

### REQ-DS-006: TaskID Sequence Generation
**SHALL** generate auto-increment sequence for TaskID.

**Scenarios:**
- SC-089: 每种simulateType独立维护序列
- SC-090: 序列从00000001开始自增
- SC-091: 获取当前最大序列号并自增

**Acceptance Criteria:**
- TaskID格式：{simulateType}{8位自增数字}
- 示例：LaWan00000001, CHOnYA00000001
- 不同工艺类型的序列独立
- 序列号持久化，服务重启后继续自增

### REQ-DS-007: Data Backup
**SHALL** support periodic database backup.

**Scenarios:**
- SC-092: 每小时自动备份数据库文件
- SC-093: 保留最近24小时的备份
- SC-094: 自动清理过期备份文件

**Acceptance Criteria:**
- 备份间隔：1小时
- 备份保留：24小时
- 自动清理过期备份
- 备份路径可配置
