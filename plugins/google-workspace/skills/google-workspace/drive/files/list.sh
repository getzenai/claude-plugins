#!/bin/bash
# List recent files from Google Drive
# Usage: list.sh [count]

source "$(dirname "$0")/../../_auth.sh"

COUNT="${1:-10}"

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?orderBy=modifiedTime%20desc&pageSize=$COUNT&fields=files(id,name,mimeType,modifiedTime,webViewLink)"
