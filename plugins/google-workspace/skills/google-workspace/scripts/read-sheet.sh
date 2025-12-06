#!/bin/bash
# Read values from a Google Sheet
# Usage: read-sheet.sh <spreadsheet_id> [range]
# Example: read-sheet.sh 1abc123xyz
# Example: read-sheet.sh 1abc123xyz "Sheet1!A1:D10"

source "$(dirname "$0")/_auth.sh"

SPREADSHEET_ID="$1"
RANGE="${2:-Sheet1!A1:Z100}"

if [ -z "$SPREADSHEET_ID" ]; then
  echo "Usage: read-sheet.sh <spreadsheet_id> [range]" >&2
  echo "Example: read-sheet.sh 1abc123xyz \"Sheet1!A1:D10\"" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://sheets.googleapis.com/v4/spreadsheets/$SPREADSHEET_ID/values/$RANGE"
