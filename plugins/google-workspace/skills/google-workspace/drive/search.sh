#!/bin/bash
# Search all files in Google Drive by content or name
# Usage: search.sh <query> [count]
# Example: search.sh "meeting notes" 10
# Example: search.sh "name contains 'report'" 5

source "$(dirname "$0")/../_auth.sh"

QUERY="$1"
COUNT="${2:-10}"

if [ -z "$QUERY" ]; then
  echo "Usage: search.sh <query> [count]" >&2
  echo "Examples:" >&2
  echo "  search.sh 'meeting notes' 10" >&2
  echo "  search.sh \"name contains 'report'\" 5" >&2
  exit 1
fi

# URL encode the query
ENCODED_QUERY=$(printf '%s' "$QUERY" | jq -sRr @uri)

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=fullText%20contains%20'$ENCODED_QUERY'&fields=files(id,name,mimeType,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc&pageSize=$COUNT"
