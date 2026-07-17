#!/usr/bin/env bash
set -euo pipefail

# Create an admin/superuser inside the running Watt backend container
# Usage: ./scripts/create-admin.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

# Extract DATABASE_URL from .env without sourcing
DATABASE_URL="$(grep '^DATABASE_URL=' .env | cut -d '=' -f2- || true)"

if [ -z "${DATABASE_URL}" ]; then
    echo "Error: DATABASE_URL not found in .env"
    exit 1
fi

echo "Creating admin user..."
docker compose -f docker-compose.yml -f docker-compose.dev.yml exec -e DATABASE_URL="${DATABASE_URL}" backend ./createadmin
