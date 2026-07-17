#!/usr/bin/env bash
set -euo pipefail

# Generate a self-signed certificate for the LOCAL_IP in .env.
# Usage: ./scripts/generate-local-cert.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

if [ ! -f .env ]; then
    echo "Error: .env file not found. Copy .env.example to .env and set LOCAL_IP."
    exit 1
fi

LOCAL_IP="$(grep '^LOCAL_IP=' .env | cut -d '=' -f2- | tr -d '[:space:]' || true)"
LOCAL_IP="${LOCAL_IP:-localhost}"

mkdir -p certs

CERT_FILE="certs/cert.pem"
KEY_FILE="certs/key.pem"

if [ -f "${CERT_FILE}" ] && [ -f "${KEY_FILE}" ]; then
    echo "Certificate already exists at ${CERT_FILE}. Skipping generation."
    echo "Remove the certs directory and re-run to regenerate."
    exit 0
fi

echo "Generating self-signed certificate for ${LOCAL_IP}..."

if command -v openssl >/dev/null 2>&1; then
    openssl req -x509 \
        -newkey rsa:2048 \
        -keyout "${KEY_FILE}" \
        -out "${CERT_FILE}" \
        -days 365 \
        -nodes \
        -subj "/CN=${LOCAL_IP}" \
        -addext "subjectAltName=IP:${LOCAL_IP}"
else
    echo "Error: openssl is required to generate the local certificate."
    exit 1
fi

echo "Certificate generated:"
echo "  ${CERT_FILE}"
echo "  ${KEY_FILE}"
