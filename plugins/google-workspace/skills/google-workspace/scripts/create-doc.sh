#!/bin/bash
# Create a new Google Doc
# Usage: create-doc.sh <title>

source "$(dirname "$0")/_auth.sh"

TITLE="$1"
if [ -z "$TITLE" ]; then
  echo "Usage: create-doc.sh <title>" >&2
  exit 1
fi

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"$TITLE\"}" \
  "https://docs.googleapis.com/v1/documents"
