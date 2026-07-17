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

# Ensure Docker daemon starts automatically on boot and is currently running.
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now docker
fi

if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    exit 1
fi

# Extract LOCAL_IP from .env without sourcing (values may contain shell-special chars)
LOCAL_IP="$(grep '^LOCAL_IP=' .env | cut -d '=' -f2- | tr -d '[:space:]' || true)"
LOCAL_IP="${LOCAL_IP:-192.168.1.107}"

mkdir -p uploads data config certs

"${SCRIPT_DIR}/generate-local-cert.sh"

echo "Building and starting Watt stack..."
docker compose pull
docker compose up --build -d

echo "Waiting for health checks..."
sleep 5
docker compose ps

# Install a systemd fallback service so the stack comes back up after reboots.
# Docker's restart policy handles containers, but this service ensures
# docker compose up -d runs once the network is ready.
if command -v systemctl >/dev/null 2>&1 && [ -f "${PROJECT_DIR}/systemd/watt.service" ]; then
    echo "Installing systemd service for auto-start after reboot..."
    sudo cp "${PROJECT_DIR}/systemd/watt.service" /etc/systemd/system/watt.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now watt.service
fi

echo "Deploy complete. Access: https://${LOCAL_IP}"
