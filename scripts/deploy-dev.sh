#!/usr/bin/env bash
set -euo pipefail

# Deploy Watt stack in DEVELOPMENT mode (HTTP only, backend on port 8080)
# Usage: ./scripts/deploy-dev.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

if [ ! -f .env ]; then
    echo "Error: .env file not found. Copy .env.example to .env and fill secrets."
    exit 1
fi

# Extract LOCAL_IP from .env without sourcing (values may contain shell-special chars)
LOCAL_IP="$(grep '^LOCAL_IP=' .env | cut -d '=' -f2- | tr -d '[:space:]' || true)"
LOCAL_IP="${LOCAL_IP:-192.168.1.100}"

mkdir -p uploads data config

echo "Building and starting Watt stack in DEVELOPMENT mode..."
docker compose -f docker-compose.yml -f docker-compose.dev.yml pull
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d

echo "Waiting for health checks..."
sleep 5
docker compose -f docker-compose.yml -f docker-compose.dev.yml ps

echo ""
echo "Dev deploy complete. Access:"
echo "  Backend direct: http://${LOCAL_IP}:8080"
echo "  Admin login:    http://${LOCAL_IP}:8080/admin/login"
echo "  Via Caddy HTTP: http://${LOCAL_IP}/admin/login"
