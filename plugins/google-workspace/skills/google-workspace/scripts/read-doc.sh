#!/bin/bash
# Read a Google Doc as plain text
# Usage: read-doc.sh <document_id>

source "$(dirname "$0")/_auth.sh"

DOC_ID="$1"
if [ -z "$DOC_ID" ]; then
  echo "Usage: read-doc.sh <document_id>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files/$DOC_ID/export?mimeType=text/plain"
