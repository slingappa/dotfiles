#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="${REPO_ROOT}/secrets"
MANIFEST_FILE="${SECRETS_DIR}/manifest.txt"
ARCHIVE_FILE="${SECRETS_DIR}/home-secrets.tar.gpg"
STAGING_DIR="${SECRETS_DIR}/.staging"
DECRYPT_DIR="${SECRETS_DIR}/.decrypted"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/secrets-vault.sh list
  ./scripts/secrets-vault.sh backup
  ./scripts/secrets-vault.sh restore [--apply]

Notes:
  - Paths in secrets/manifest.txt are interpreted relative to $HOME.
  - backup: copies manifest paths and writes encrypted secrets/home-secrets.tar.gpg.
  - restore: decrypts archive and shows files to be restored (dry-run).
  - restore --apply: writes files back into $HOME.
  - Optional env for non-interactive gpg:
      DOTFILES_SECRETS_PASSPHRASE
EOF
}

require_manifest() {
  if [[ ! -f "${MANIFEST_FILE}" ]]; then
    echo "Missing manifest: ${MANIFEST_FILE}" >&2
    exit 1
  fi
}

gpg_common_args() {
  if [[ -n "${DOTFILES_SECRETS_PASSPHRASE:-}" ]]; then
    echo "--batch --yes --pinentry-mode loopback --passphrase ${DOTFILES_SECRETS_PASSPHRASE}"
  fi
}

list_manifest() {
  require_manifest
  while IFS= read -r raw || [[ -n "${raw}" ]]; do
    line="${raw#"${raw%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line:0:1}" == "#" ]] && continue
    src="${HOME}/${line}"
    if [[ -e "${src}" ]]; then
      echo "[OK]    ${line}"
    else
      echo "[MISS]  ${line}"
    fi
  done < "${MANIFEST_FILE}"
}

backup_secrets() {
  require_manifest
  rm -rf "${STAGING_DIR}"
  mkdir -p "${STAGING_DIR}"

  copied=0
  while IFS= read -r raw || [[ -n "${raw}" ]]; do
    line="${raw#"${raw%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line:0:1}" == "#" ]] && continue

    if [[ "${line}" == /* ]]; then
      echo "Skipping absolute path in manifest (must be home-relative): ${line}" >&2
      continue
    fi

    src="${HOME}/${line}"
    dst="${STAGING_DIR}/${line}"
    if [[ ! -e "${src}" ]]; then
      echo "Missing path, skipping: ${line}" >&2
      continue
    fi

    mkdir -p "$(dirname "${dst}")"
    cp -a "${src}" "${dst}"
    copied=$((copied + 1))
  done < "${MANIFEST_FILE}"

  if [[ "${copied}" -eq 0 ]]; then
    echo "Nothing copied from manifest; not creating archive." >&2
    exit 1
  fi

  mkdir -p "${SECRETS_DIR}"
  tmp_archive="${ARCHIVE_FILE}.tmp"

  extra_args="$(gpg_common_args)"
  # shellcheck disable=SC2086
  tar -C "${STAGING_DIR}" -cf - . | gpg ${extra_args} --symmetric --cipher-algo AES256 -o "${tmp_archive}"
  mv -f "${tmp_archive}" "${ARCHIVE_FILE}"
  rm -rf "${STAGING_DIR}"

  echo "Encrypted archive updated: ${ARCHIVE_FILE}"
}

restore_secrets() {
  apply_mode="${1:-}"
  if [[ ! -f "${ARCHIVE_FILE}" ]]; then
    echo "Missing archive: ${ARCHIVE_FILE}" >&2
    exit 1
  fi

  rm -rf "${DECRYPT_DIR}"
  mkdir -p "${DECRYPT_DIR}"

  extra_args="$(gpg_common_args)"
  # shellcheck disable=SC2086
  gpg ${extra_args} -d "${ARCHIVE_FILE}" | tar -C "${DECRYPT_DIR}" -xf -

  echo "Decrypted files:"
  (cd "${DECRYPT_DIR}" && find . -mindepth 1 -print | sed 's#^\./##')

  if [[ "${apply_mode}" == "--apply" ]]; then
    rsync -a "${DECRYPT_DIR}/" "${HOME}/"
    echo "Restore applied to ${HOME}"
  else
    echo "Dry-run only. Re-run with: ./scripts/secrets-vault.sh restore --apply"
  fi
}

main() {
  cmd="${1:-}"
  case "${cmd}" in
    list)
      list_manifest
      ;;
    backup)
      backup_secrets
      ;;
    restore)
      restore_secrets "${2:-}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "${@:-}"
