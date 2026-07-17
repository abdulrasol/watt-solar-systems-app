#!/usr/bin/env bash
set -euo pipefail

# Deploy Watt stack locally
# Usage: ./scripts/deploy.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

if [ ! -f .env ]; then
    echo "Error: .env file not found. Copy .env.example to .env and fill secrets."
    exit 1
fi

# Extract LOCAL_IP from .env without sourcing (values may contain shell-special chars)
LOCAL_IP="$(grep '^LOCAL_IP=' .env | cut -d '=' -f2- | tr -d '[:space:]' || true)"
LOCAL_IP="${LOCAL_IP:-192.168.1.107}"

mkdir -p uploads data config

echo "Building and starting Watt stack..."
docker compose pull
docker compose up --build -d

echo "Waiting for health checks..."
sleep 5
docker compose ps

echo "Deploy complete. Access: https://${LOCAL_IP}"
