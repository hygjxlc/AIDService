# File Management Module Specification

## Overview
处理SDK端的参数文件上传、覆盖、存储，校验文件名称与类型合法性，管理仿真任务的参数文件。

## Added Requirements

### REQ-FM-001: Parameter File Upload (uploadParamfiles)
**SHALL** provide API to upload simulation parameter files for a task.

**Scenarios:**
- SC-031: 上传单个合法参数文件，返回成功
- SC-032: 上传多个合法参数文件，返回成功
- SC-033: 上传同名文件覆盖已有文件
- SC-034: 上传非法格式文件，标记为失败
- SC-035: 上传超大文件(>100MB)，标记为失败
- SC-036: TaskID不存在，返回404错误

**Acceptance Criteria:**
- 支持单文件/多文件上传
- 文件名需严格对应系统指定名称
- 文件格式限制：stp/txt/csv/yml/jnl
- 单文件大小≤100MB
- 支持覆盖已上传的同名文件
- 按TaskID分目录存储文件
- 返回成功/失败文件列表

**Input Parameters:**
| 参数 | 类型 | 必选 | 约束 |
|-----|------|-----|------|
| TaskID | string | 是 | 符合TaskID生成规则 |
| files | file_array | 是 | 文件流数组 |

**Response:**
| 字段 | 类型 | 说明 |
|-----|------|------|
| code | int | 200成功，303失败，404任务不存在 |
| message | string | 响应描述 |
| taskID | string | 任务ID |
| uploadFiles | array | 成功上传的文件列表 |
| failFiles | array | 上传失败的文件列表 |

### REQ-FM-002: Required File Validation
**SHALL** validate file names against required file list.

**Scenarios:**
- SC-037: 上传config.yml文件，验证通过
- SC-038: 上传feature_line_ref_0.stp文件，验证通过
- SC-039: 上传非系统指定文件名，验证失败

**Acceptance Criteria:**
- 必选文件列表：
  - config.yml
  - feature_line_ref_0.stp/.txt
  - feature_line_ref_1.stp/.txt
  - left_boundary.txt
  - materials.csv
  - mould_section.stp
  - strip_section.stp
- 可选文件列表：
  - product.stp
  - mesh.jnl
  - support_side_mould_x.stp
  - support_up_mould_x.stp
  - rubber_section.stp
- 文件名大小写不敏感

### REQ-FM-003: File Format Validation
**SHALL** validate uploaded file formats.

**Scenarios:**
- SC-040: 上传.stp格式文件，验证通过
- SC-041: 上传.txt格式文件，验证通过
- SC-042: 上传.exe格式文件，验证失败

**Acceptance Criteria:**
- 允许格式：stp, txt, csv, yml, jnl
- 拒绝其他所有格式
- 防止恶意文件上传

### REQ-FM-004: File Size Validation
**SHALL** validate uploaded file sizes.

**Scenarios:**
- SC-043: 上传50MB文件，验证通过
- SC-044: 上传100MB文件，验证通过
- SC-045: 上传150MB文件，验证失败

**Acceptance Criteria:**
- 单文件大小≤100MB
- 超过大小限制的文件标记为失败
- 返回清晰的大小超限错误信息

### REQ-FM-005: File Storage Management
**SHALL** manage file storage on server with proper organization.

**Scenarios:**
- SC-046: 新文件存储到TaskID对应目录
- SC-047: 同名文件覆盖已有文件
- SC-048: 删除任务时清理所有文件

**Acceptance Criteria:**
- 按TaskID分目录存储：/data/aid/{TaskID}/
- 同名文件直接覆盖
- 目录权限设置为仅服务端进程可读写
- 任务删除时清理对应目录

### REQ-FM-006: File Info Persistence
**SHALL** persist file information to SQLite database.

**Scenarios:**
- SC-049: 上传文件后记录到file_info表
- SC-050: 覆盖文件后更新file_info记录
- SC-051: 删除任务时删除file_info记录

**Acceptance Criteria:**
- 记录字段：file_id, task_id, file_name, file_path, file_size, upload_time, file_type
- file_type标记为required/optional
- 支持按TaskID查询已上传文件列表
