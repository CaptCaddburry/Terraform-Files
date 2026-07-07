#!/bin/bash
set -Eeuo pipefail

trap 'echo "Error at line $LINENO"; exit 1' ERR

set -a
[ -f .env ] && . ./.env
set +a

: "${TF_VAR_APP_NAME:?TF_VAR_APP_NAME is required}"
: "${TF_VAR_VERSION:?TF_VAR_VERSION is required}"

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

build_image() {
    log "Building image..."
    docker build --no-cache -f app/Dockerfile -t "$TF_VAR_APP_NAME:$TF_VAR_VERSION" .
}

scan_image() {
    log "Generating SBOM..."
    docker scout sbom --output "./output/${TF_VAR_APP_NAME}.sbom" "$TF_VAR_APP_NAME:$TF_VAR_VERSION"

    log "Generating vulnerability report..."
    docker scout cves "$TF_VAR_APP_NAME:$TF_VAR_VERSION" --output "./output/vulns.report"

    log "Checking critical vulnerabilities..."
    docker scout cves "$TF_VAR_APP_NAME:$TF_VAR_VERSION" --only-severity critical --exit-code
}

deploy() {
    log "Deploying infrastructure..."
    terraform init
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan
}

build_image
scan_image
deploy

log "Pipeline completed successfully."