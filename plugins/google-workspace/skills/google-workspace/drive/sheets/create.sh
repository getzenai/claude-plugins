#!/bin/bash
# Create a new Google Sheet
# Usage: create.sh <title> [folder_id]
# Example: create.sh "My New Spreadsheet"
# Example: create.sh "My New Spreadsheet" 1abc123xyz

source "$(dirname "$0")/../../_auth.sh"

TITLE="$1"
FOLDER_ID="$2"

if [ -z "$TITLE" ]; then
  echo "Usage: create.sh <title> [folder_id]" >&2
  exit 1
fi

if [ -n "$FOLDER_ID" ]; then
  METADATA="{\"name\": \"$TITLE\", \"mimeType\": \"application/vnd.google-apps.spreadsheet\", \"parents\": [\"$FOLDER_ID\"]}"
else
  METADATA="{\"name\": \"$TITLE\", \"mimeType\": \"application/vnd.google-apps.spreadsheet\"}"
fi

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$METADATA" \
  "https://www.googleapis.com/drive/v3/files?fields=id,name,webViewLink"
