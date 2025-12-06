#!/bin/bash
# Upload a file to Google Drive
# Usage: upload.sh <local_path> [folder_id]
# Example: upload.sh ./report.pdf
# Example: upload.sh ./report.pdf 1abc123xyz

source "$(dirname "$0")/../../_auth.sh"

LOCAL_PATH="$1"
FOLDER_ID="$2"

if [ -z "$LOCAL_PATH" ]; then
  echo "Usage: upload.sh <local_path> [folder_id]" >&2
  exit 1
fi

if [ ! -f "$LOCAL_PATH" ]; then
  echo "Error: File not found: $LOCAL_PATH" >&2
  exit 1
fi

FILENAME=$(basename "$LOCAL_PATH")

if [ -n "$FOLDER_ID" ]; then
  METADATA="{\"name\": \"$FILENAME\", \"parents\": [\"$FOLDER_ID\"]}"
else
  METADATA="{\"name\": \"$FILENAME\"}"
fi

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata=$METADATA;type=application/json;charset=UTF-8" \
  -F "file=@$LOCAL_PATH" \
  "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id,name,webViewLink"
