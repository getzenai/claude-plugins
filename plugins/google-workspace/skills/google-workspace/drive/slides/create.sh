#!/bin/bash
# Create a new Google Slides presentation
# Usage: create.sh <title> [folder_id]
# Example: create.sh "My New Presentation"
# Example: create.sh "My New Presentation" 1abc123xyz

source "$(dirname "$0")/../../_auth.sh"

TITLE="$1"
FOLDER_ID="$2"

if [ -z "$TITLE" ]; then
  echo "Usage: create.sh <title> [folder_id]" >&2
  exit 1
fi

if [ -n "$FOLDER_ID" ]; then
  METADATA="{\"name\": \"$TITLE\", \"mimeType\": \"application/vnd.google-apps.presentation\", \"parents\": [\"$FOLDER_ID\"]}"
else
  METADATA="{\"name\": \"$TITLE\", \"mimeType\": \"application/vnd.google-apps.presentation\"}"
fi

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$METADATA" \
  "https://www.googleapis.com/drive/v3/files?fields=id,name,webViewLink"
