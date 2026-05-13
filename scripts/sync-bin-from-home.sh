#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_BIN="${1:-${HOME}/bin}"

if [[ ! -e "${SRC_BIN}" ]]; then
  echo "Source path not found: ${SRC_BIN}" >&2
  exit 1
fi

mkdir -p "${REPO_ROOT}/bin"
rsync -rlptD --delete "$(readlink -f "${SRC_BIN}")"/ "${REPO_ROOT}/bin/"
echo "Synced ${SRC_BIN} -> ${REPO_ROOT}/bin"
