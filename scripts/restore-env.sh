#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_SECRETS=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/restore-env.sh [--with-secrets]

What it does:
  1) Recreates symlinks for managed dotfiles (including ~/bin -> ~/dotfiles/bin)
  2) Optionally restores encrypted secrets into $HOME
  3) Applies secure permissions on secret directories if present

Secrets restore:
  - Pass --with-secrets, or
  - Set DOTFILES_RESTORE_SECRETS=1
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-secrets)
      WITH_SECRETS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "${DOTFILES_RESTORE_SECRETS:-0}" == "1" ]]; then
  WITH_SECRETS=1
fi

cd "${REPO_ROOT}"

./create_links.sh

if [[ "${WITH_SECRETS}" -eq 1 ]]; then
  if [[ -f "${REPO_ROOT}/secrets/home-secrets.tar.gpg" ]]; then
    ./scripts/secrets-vault.sh restore --apply
  else
    echo "No encrypted archive found at secrets/home-secrets.tar.gpg; skipping restore."
  fi
else
  echo "Secrets restore skipped. Re-run with --with-secrets when needed."
fi

[[ -d "${HOME}/.ssh" ]] && chmod 700 "${HOME}/.ssh" || true
[[ -d "${HOME}/.gnupg" ]] && chmod 700 "${HOME}/.gnupg" || true
[[ -d "${HOME}/.secrets" ]] && chmod 700 "${HOME}/.secrets" || true
[[ -f "${HOME}/.config/shell/private.zsh" ]] && chmod 600 "${HOME}/.config/shell/private.zsh" || true

echo "Restore complete."
