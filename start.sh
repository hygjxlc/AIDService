#!/bin/bash
# AID-Service Startup Script (Linux/macOS)
cd "$(dirname "$0")"

# Read host and port from app_config.yaml (fallback to defaults if not set)
AID_PORT=$(grep -E "^  port:" app_config.yaml 2>/dev/null | awk '{print $2}')
AID_HOST=$(grep -E "^  host:" app_config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"')
AID_PORT=${AID_PORT:-8080}
AID_HOST=${AID_HOST:-0.0.0.0}

python -m uvicorn src.main:app --host "$AID_HOST" --port "$AID_PORT" --reload
