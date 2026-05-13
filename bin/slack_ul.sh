#!/usr/bin/env bash
set -euo pipefail

# Usage: ./slack_file_upload.sh /path/to/file.txt U12345678 "Optional message"

# --- Config ---
: "${SLACK_BOT_TOKEN:?Set SLACK_BOT_TOKEN}"
TOKEN="${SLACK_BOT_TOKEN}"
FILE_PATH="${1:-}"
TARGET="${2:-${SLACK_TARGET_ID:-U09FT7TJ55}}"
COMMENT="${3:-Uploaded via CLI}"
FILENAME=$(basename "$FILE_PATH")

# --- Validate Inputs ---
if [[ -z "${FILE_PATH}" || ! -f "$FILE_PATH" ]]; then
  echo "❌ File not found: $FILE_PATH"
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  echo "❌ Usage: $0 /path/to/file TARGET_ID [optional_comment]"
  exit 1
fi

FILE_SIZE=$(stat --printf="%s" "$FILE_PATH")
MIME_TYPE=$(file -b --mime-type "$FILE_PATH")

# --- Step 1: Get Upload URL ---

FILENAME=$(basename "$FILE_PATH")
FILE_SIZE=$(stat --printf="%s" "$FILE_PATH")
MIME_TYPE=$(file -b --mime-type "$FILE_PATH")

RESPONSE=$(curl -v -s -X POST https://slack.com/api/files.getUploadURLExternal \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json; charset=utf-8" \
    -d "filename=$FILENAME" \
    -d "length=$FILE_SIZE" \
    -d "filetype=$MIME_TYPE"
)

#RESPONSE=$( curl \
#	-H "Authorization: Bearer $TOKEN" \
#	-H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
#	-d "filename=file.txt" \
#	-d "length='"$FILE_SIZE"'" \
#	https://slack.com/api/files.getUploadURLExternal | jq .
#)
RESPONSE=$( curl \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
	-d "filename=file.txt" \
	-d "length=49" \
	https://slack.com/api/files.getUploadURLExternal
)



echo DEBUG: FILENAME: $FILENAME
echo DEBUG: FILE_SIZE: $FILE_SIZE
echo DEBUG: RESPONSE: $RESPONSE
echo $RESPONSE > ./tmp_resp

UPLOAD_URL=$(cat tmp_resp | jq -r '.upload_url')
FILE_ID=$(cat tmp_resp | jq -r '.file_id')

echo DEBUG: URL: $UPLOAD_URL
echo DEBUG: URL: $FILE_ID

if [[ "$UPLOAD_URL" == "null" || "$FILE_ID" == "null" ]]; then
  echo "❌ Failed to get upload URL:"
  echo "$RESPONSE"
  exit 1
fi

echo "✅ Got upload URL and file ID"

# --- Step 2: Upload File to Pre-signed URL ---
UPLOAD_RESULT=$(curl -s -X POST "$UPLOAD_URL" \
  -F "file=@$FILE_PATH")

echo DEBUG: UPLOAD RESULT: $UPLOAD_RESULT

if [[ "$UPLOAD_RESULT" != *"OK"* && "$UPLOAD_RESULT" != *"success"* ]]; then
  echo "❌ Failed to upload file to upload_url"
  echo "$UPLOAD_RESULT"
  exit 1
fi

echo "✅ File uploaded to Slack server"

FINAL_RESPONSE=$(curl -s -X POST https://slack.com/api/files.completeUploadExternal \
	  -H "Authorization: Bearer $TOKEN" \
	    -H "Content-Type: application/json" \
		-d @<(cat <<EOF
		{
		"file_id": "$FILE_ID",
    	"channels": "$TARGET",
		"initial_comment": "$COMMENT",
		"title": "$FILENAME"
	}
	EOF
	))

  echo "$FINAL_RESPONSE"


## --- Step 3: Complete the Upload ---
#COMPLETE_RESPONSE=$(curl -v -s -X POST https://slack.com/api/files.completeUploadExternal \
#  -H "Authorization: Bearer $TOKEN" \
#  -H "Content-Type: application/json; charset=utf-8" \
#  -d "{
#    \"file_id\": \"$FILE_ID\",
#    \"channels\": U09FT7TJ55,
#    \"initial_comment\": \"$COMMENT\",
#    \"title\": \"$FILENAME\"
#  }")
#
#OK=$(echo "$COMPLETE_RESPONSE" | jq -r '.ok')
#
#if [[ "$OK" != "true" ]]; then
#  echo "❌ Failed to complete upload:"
#  echo "$COMPLETE_RESPONSE"
#  exit 1
#fi
#
#echo "✅ File successfully uploaded and shared to $TARGET"
