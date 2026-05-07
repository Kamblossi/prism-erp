#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="prism-dev"
COMPOSE_FILE="/opt/prismerp/gitops/prism-dev/docker-compose.yml"
BACKUP_ROOT="/opt/prismerp/backups/manual"
LOG_ROOT="/opt/prismerp/backups/logs"
SITES=(
  "dev-erp.prismtechco.com"
  "tenant1-dev-erp.prismtechco.com"
)

TS="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="${BACKUP_ROOT}/${TS}"
LOG_FILE="${LOG_ROOT}/backup-${TS}.log"

mkdir -p "${RUN_DIR}" "${LOG_ROOT}"
chmod 700 "${BACKUP_ROOT}" "${LOG_ROOT}" "${RUN_DIR}"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" | tee -a "${LOG_FILE}"
}

log "Starting PrismERP dev backup run: ${TS}"

docker compose \
  --project-name "${STACK_NAME}" \
  -f "${COMPOSE_FILE}" \
  ps | tee -a "${LOG_FILE}"

for SITE in "${SITES[@]}"; do
  log "Backing up site: ${SITE}"

  docker compose \
    --project-name "${STACK_NAME}" \
    -f "${COMPOSE_FILE}" \
    exec -T backend bash -lc "bench --site '${SITE}' backup --with-files" \
    | tee -a "${LOG_FILE}"

  SITE_RUN_DIR="${RUN_DIR}/${SITE}"
  mkdir -p "${SITE_RUN_DIR}"
  chmod 700 "${SITE_RUN_DIR}"

  log "Copying backup artifacts for ${SITE}"

  LATEST_BACKUPS="$(
    sudo find /mnt/prismerp-data/docker/volumes/frappe_docker_sites/_data/${SITE}/private/backups \
      -maxdepth 1 \
      -type f \
      -printf '%T@ %p\n' \
      2>/dev/null \
      | sort -nr \
      | head -20 \
      | awk '{print $2}'
  )"

  if [ -z "${LATEST_BACKUPS}" ]; then
    log "ERROR: No backup files found for ${SITE}"
    exit 1
  fi

  while IFS= read -r FILE; do
    [ -n "${FILE}" ] || continue
    sudo cp "${FILE}" "${SITE_RUN_DIR}/"
  done <<< "${LATEST_BACKUPS}"

  sudo chown -R "$(id -u):$(id -g)" "${SITE_RUN_DIR}"
  chmod 600 "${SITE_RUN_DIR}"/* || true

  log "Copied backup artifacts for ${SITE}"
done

MANIFEST="${RUN_DIR}/MANIFEST.txt"

{
  echo "PrismERP backup run: ${TS}"
  echo "Stack: ${STACK_NAME}"
  echo "Sites:"
  printf ' - %s\n' "${SITES[@]}"
  echo
  echo "Files:"
  find "${RUN_DIR}" -type f -printf '%p\t%s bytes\n' | sort
} > "${MANIFEST}"

chmod 600 "${MANIFEST}"

log "Backup run completed successfully"
log "Backup directory: ${RUN_DIR}"
log "Manifest: ${MANIFEST}"
