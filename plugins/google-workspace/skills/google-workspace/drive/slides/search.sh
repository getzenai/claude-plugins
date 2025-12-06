#!/bin/bash
# Search Google Slides by name
# Usage: search.sh <query>
# Example: search.sh "quarterly review"

source "$(dirname "$0")/../../_auth.sh"

QUERY="$1"

if [ -z "$QUERY" ]; then
  echo "Usage: search.sh <query>" >&2
  exit 1
fi

ENCODED_QUERY=$(printf '%s' "$QUERY" | jq -sRr @uri)

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=mimeType%3D%27application/vnd.google-apps.presentation%27%20and%20name%20contains%20%27${ENCODED_QUERY}%27&fields=files(id,name,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc"
