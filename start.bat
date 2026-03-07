@echo off
REM AID-Service Startup Script (Windows)
cd /d %~dp0

REM Read host and port from app_config.yaml (fallback to defaults if not set)
for /f "tokens=2 delims=: " %%a in ('findstr /r "^  port:" app_config.yaml 2^>nul') do set AID_PORT=%%a
for /f "tokens=2 delims=: " %%a in ('findstr /r "^  host:" app_config.yaml 2^>nul') do set AID_HOST=%%a
if not defined AID_PORT set AID_PORT=8080
if not defined AID_HOST set AID_HOST=0.0.0.0

python -m uvicorn src.main:app --host %AID_HOST% --port %AID_PORT% --reload
