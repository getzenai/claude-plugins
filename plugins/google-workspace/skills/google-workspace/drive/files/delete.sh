#!/bin/bash
# Delete a file from Google Drive (moves to trash)
# Usage: delete.sh <file_id>
# Example: delete.sh 1abc123xyz

source "$(dirname "$0")/../../_auth.sh"

FILE_ID="$1"

if [ -z "$FILE_ID" ]; then
  echo "Usage: delete.sh <file_id>" >&2
  exit 1
fi

# Move to trash instead of permanent delete for safety
curl -s -X PATCH -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"trashed": true}' \
  "https://www.googleapis.com/drive/v3/files/$FILE_ID"

echo "File moved to trash: $FILE_ID"
