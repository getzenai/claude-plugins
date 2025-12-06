#!/bin/bash
# Download a file from Google Drive
# Usage: download.sh <file_id> <output_path>
# Example: download.sh 1abc123xyz ./downloaded_file.pdf

source "$(dirname "$0")/../../_auth.sh"

FILE_ID="$1"
OUTPUT_PATH="$2"

if [ -z "$FILE_ID" ] || [ -z "$OUTPUT_PATH" ]; then
  echo "Usage: download.sh <file_id> <output_path>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files/$FILE_ID?alt=media" \
  -o "$OUTPUT_PATH"

echo "Downloaded to: $OUTPUT_PATH"
