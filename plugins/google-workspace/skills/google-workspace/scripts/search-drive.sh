#!/bin/bash
# Search Google Drive files
# Usage: search-drive.sh <query> [count]
# Example: search-drive.sh "meeting notes" 10
# Example: search-drive.sh "name contains 'report'" 5

source "$(dirname "$0")/_auth.sh"

QUERY="$1"
COUNT="${2:-10}"

if [ -z "$QUERY" ]; then
  echo "Usage: search-drive.sh <query> [count]" >&2
  echo "Examples:" >&2
  echo "  search-drive.sh 'meeting notes' 10" >&2
  echo "  search-drive.sh \"name contains 'report'\" 5" >&2
  exit 1
fi

# URL encode the query
ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=fullText%20contains%20'$ENCODED_QUERY'&fields=files(id,name,mimeType,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc&pageSize=$COUNT"
