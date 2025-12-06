#!/bin/bash
# List recent Google Sheets
# Usage: list.sh [count]

source "$(dirname "$0")/../../_auth.sh"

COUNT="${1:-10}"

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=mimeType%3D%27application/vnd.google-apps.spreadsheet%27&fields=files(id,name,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc&pageSize=$COUNT"
