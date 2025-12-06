#!/bin/bash
# Write/append text to a Google Doc
# Usage: write.sh <doc_id> <text> [index]
# Example: write.sh 1abc123xyz "Hello, World!"
# Example: write.sh 1abc123xyz "Appended text" 1  (insert at beginning)

source "$(dirname "$0")/../../_auth.sh"

DOC_ID="$1"
TEXT="$2"
INDEX="${3:-1}"

if [ -z "$DOC_ID" ] || [ -z "$TEXT" ]; then
  echo "Usage: write.sh <doc_id> <text> [index]" >&2
  exit 1
fi

# Escape special characters in text for JSON
ESCAPED_TEXT=$(echo "$TEXT" | jq -Rs '.')

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"requests\": [
      {
        \"insertText\": {
          \"location\": {
            \"index\": $INDEX
          },
          \"text\": $ESCAPED_TEXT
        }
      }
    ]
  }" \
  "https://docs.googleapis.com/v1/documents/$DOC_ID:batchUpdate"
