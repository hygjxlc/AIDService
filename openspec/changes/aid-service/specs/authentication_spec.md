# Authentication Module Specification

## Overview
实现SDK与AID-service之间的基础身份认证，仅允许携带合法API Key的SDK请求访问服务端接口；预留认证服务扩展接口，支持后续替换为更完善的鉴权方案。

## Added Requirements

### REQ-AUTH-001: API Key Authentication
**SHALL** implement fixed API Key authentication mechanism.

**Scenarios:**
- SC-001: SDK请求携带合法API Key (11111111)，放行进入后续业务处理
- SC-002: SDK请求携带非法API Key，直接拒绝并返回401错误码
- SC-003: SDK请求未携带API Key，直接拒绝并返回401错误码

**Acceptance Criteria:**
- 本期指定统一API Key为：11111111，无其他合法密钥
- SDK调用所有接口时，必须携带api_key字段
- 认证逻辑为所有接口的前置拦截逻辑
- 认证失败返回code=401，message="API Key认证失败，无效的密钥"

### REQ-AUTH-002: Authentication Interceptor
**SHALL** implement authentication as pre-interceptor for all API endpoints.

**Scenarios:**
- SC-004: 认证拦截器在所有业务逻辑之前执行
- SC-005: 认证通过后，请求继续进入业务处理流程
- SC-006: 认证失败后，请求立即返回，不进入任何业务逻辑

**Acceptance Criteria:**
- 所有9个API端点均需前置认证校验
- 认证模块与业务模块解耦
- 未通过认证的请求无法进入后续业务处理

### REQ-AUTH-003: Authentication Extension Interface
**SHALL** reserve extension interfaces for future authentication methods.

**Scenarios:**
- SC-007: 预留Token认证扩展接口
- SC-008: 预留OAuth2.0认证扩展接口
- SC-009: 替换认证方案时无需修改核心业务代码

**Acceptance Criteria:**
- 认证模块提供标准化扩展接口
- 支持后续无缝切换到Token、OAuth2.0等鉴权方案
- 核心业务代码与认证实现隔离

### REQ-AUTH-004: API Key Configuration
**SHALL** read API Key from configuration file, not hardcoded.

**Scenarios:**
- SC-010: 从配置文件读取API Key值
- SC-011: 配置文件缺失时抛出明确异常

**Acceptance Criteria:**
- API Key不允许硬编码在代码中
- 通过配置文件管理API Key
- 配置异常时提供清晰错误提示
