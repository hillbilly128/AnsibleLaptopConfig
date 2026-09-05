#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_FILE="${SCRIPT_DIR}/playbook.yml"
REQUIREMENTS_FILE="${SCRIPT_DIR}/requirements.yml"
INVENTORY_FILE="${SCRIPT_DIR}/inventory.ini"

INSTALL_COLLECTIONS=1

usage() {
  cat <<'EOF'
Usage:
  ./run-playbook.sh [runner-options] [-- ansible-playbook-options]

Runner options:
  --skip-collections   Do not run `ansible-galaxy collection install -r requirements.yml`
  --help               Show this help text

Examples:
  ./run-playbook.sh
  ./run-playbook.sh -- --check --diff
  ./run-playbook.sh --skip-collections -- -e openclaw_default_model=qwen2.5:14b

Notes:
  - Bitwarden login and secret retrieval now happen inside `playbook.yml`.
  - The playbook will prompt for your Bitwarden email and master password.
  - Pass extra `ansible-playbook` arguments after `--`.
EOF
}

log() {
  printf '[run-playbook] %s\n' "$*"
}

die() {
  printf '[run-playbook] ERROR: %s\n' "$*" >&2
  exit 1
}

ensure_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

parse_args() {
  PLAYBOOK_ARGS=()

  while (($#)); do
    case "$1" in
      --skip-collections)
        INSTALL_COLLECTIONS=0
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --)
        shift
        PLAYBOOK_ARGS=("$@")
        break
        ;;
      *)
        PLAYBOOK_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

maybe_install_collections() {
  if [[ "${INSTALL_COLLECTIONS}" -eq 1 ]]; then
    log "Installing required Ansible collections from ${REQUIREMENTS_FILE##*/}."
    ansible-galaxy collection install -r "${REQUIREMENTS_FILE}"
  fi
}

run_playbook() {
  export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-/tmp/ansible-local}"
  export ANSIBLE_REMOTE_TEMP="${ANSIBLE_REMOTE_TEMP:-/tmp/ansible-remote}"
  export BITWARDENCLI_APPDATA_DIR="${BITWARDENCLI_APPDATA_DIR:-${SCRIPT_DIR}/.bitwarden-cli}"
  mkdir -p "${ANSIBLE_LOCAL_TEMP}" "${ANSIBLE_REMOTE_TEMP}" "${BITWARDENCLI_APPDATA_DIR}"

  log "Executing ${PLAYBOOK_FILE##*/}."
  ansible-playbook -i "${INVENTORY_FILE}" "${PLAYBOOK_FILE}" "${PLAYBOOK_ARGS[@]}"
}

main() {
  parse_args "$@"

  ensure_command ansible-playbook
  ensure_command ansible-galaxy
  ensure_command bw
  ensure_command python3

  [[ -f "${PLAYBOOK_FILE}" ]] || die "Playbook not found: ${PLAYBOOK_FILE}"
  [[ -f "${REQUIREMENTS_FILE}" ]] || die "Requirements file not found: ${REQUIREMENTS_FILE}"
  [[ -f "${INVENTORY_FILE}" ]] || die "Inventory file not found: ${INVENTORY_FILE}"

  maybe_install_collections
  run_playbook
}

main "$@"
