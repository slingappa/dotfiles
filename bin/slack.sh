#!/usr/bin/env bash
set -euo pipefail

: "${SLACK_BOT_TOKEN:?Set SLACK_BOT_TOKEN}"

SLACK_TARGET="${SLACK_TARGET_ID:-U09FT7TJ55}"
FILE_PATH="${1:-/home/redpanda/git/ventana_openbmc_ws/ventana-sw-0.19.1-rc2/results.csv}"

curl -X POST https://slack.com/api/files.upload \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -F "channels=${SLACK_TARGET}" \
  -F "initial_comment=Here is the file" \
  -F "file=@${FILE_PATH}"
