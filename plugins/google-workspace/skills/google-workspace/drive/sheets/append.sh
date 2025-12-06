#!/bin/bash
set +H  # Disable history expansion to handle ! in ranges
# Append rows to a Google Sheet
# Usage: append.sh <spreadsheet_id> <range> <values_json>
# Example: append.sh 1abc123xyz "Sheet1!A:B" '[["John",30],["Jane",25]]'

source "$(dirname "$0")/../../_auth.sh"

SPREADSHEET_ID="$1"
RANGE="$2"
VALUES="$3"

if [ -z "$SPREADSHEET_ID" ] || [ -z "$RANGE" ] || [ -z "$VALUES" ]; then
  echo "Usage: append.sh <spreadsheet_id> <range> <values_json>" >&2
  echo "Example: append.sh 1abc123xyz \"Sheet1!A:B\" '[[\"John\",30],[\"Jane\",25]]'" >&2
  exit 1
fi

# URL encode the range using python for reliability
ENCODED_RANGE=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$RANGE")

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"range\": \"$RANGE\",
    \"majorDimension\": \"ROWS\",
    \"values\": $VALUES
  }" \
  "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID/values/$ENCODED_RANGE:append?valueInputOption=USER_ENTERED&insertDataOption=INSERT_ROWS"
