#!/bin/bash
set +H  # Disable history expansion to handle ! in ranges
# Read data from a Google Sheet
# Usage: read.sh <spreadsheet_id> [range]
# Example: read.sh 1abc123xyz
# Example: read.sh 1abc123xyz "Sheet1!A1:D10"

source "$(dirname "$0")/../../_auth.sh"

SPREADSHEET_ID="$1"
RANGE="$2"

if [ -z "$SPREADSHEET_ID" ]; then
  echo "Usage: read.sh <spreadsheet_id> [range]" >&2
  exit 1
fi

if [ -n "$RANGE" ]; then
  # URL encode the range using python for reliability
  ENCODED_RANGE=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$RANGE")
  curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID/values/$ENCODED_RANGE"
else
  # Get spreadsheet metadata and all sheet names
  curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID?includeGridData=false"
fi
