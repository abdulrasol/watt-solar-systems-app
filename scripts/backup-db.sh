#!/usr/bin/env bash
set -euo pipefail

# Backup Watt MariaDB database
# Usage: ./scripts/backup-db.sh [backup_dir]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_DIR="${1:-${PROJECT_DIR}/backups}"

cd "${PROJECT_DIR}"

if [ ! -f .env ]; then
    echo "Error: .env file not found."
    exit 1
fi

# Extract values from .env without sourcing (values may contain shell-special chars)
MARIADB_ROOT_PASSWORD="$(grep '^MARIADB_ROOT_PASSWORD=' .env | cut -d '=' -f2- | tr -d '[:space:]' || true)"
MARIADB_DATABASE="$(grep '^MARIADB_DATABASE=' .env | cut -d '=' -f2 | tr -d '[:space:]' || true)"
MARIADB_DATABASE="${MARIADB_DATABASE:-watt}"

if [ -z "${MARIADB_ROOT_PASSWORD}" ]; then
    echo "Error: MARIADB_ROOT_PASSWORD not found in .env"
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/watt_db_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

echo "Creating backup: ${BACKUP_FILE}"
docker compose exec -T mariadb mariadb-dump \
    -u root \
    -p"${MARIADB_ROOT_PASSWORD}" \
    --single-transaction \
    --routines \
    --triggers \
    "${MARIADB_DATABASE}" > "${BACKUP_FILE}"

echo "Backup complete: ${BACKUP_FILE}"
