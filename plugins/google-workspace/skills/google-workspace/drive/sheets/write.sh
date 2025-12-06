#!/bin/bash
set +H  # Disable history expansion to handle ! in ranges
# Write data to a Google Sheet (overwrites existing data in range)
# Usage: write.sh <spreadsheet_id> <range> <values_json>
# Example: write.sh 1abc123xyz "Sheet1!A1:B2" '[["Name","Age"],["John",30]]'

source "$(dirname "$0")/../../_auth.sh"

SPREADSHEET_ID="$1"
RANGE="$2"
VALUES="$3"

if [ -z "$SPREADSHEET_ID" ] || [ -z "$RANGE" ] || [ -z "$VALUES" ]; then
  echo "Usage: write.sh <spreadsheet_id> <range> <values_json>" >&2
  echo "Example: write.sh 1abc123xyz \"Sheet1!A1:B2\" '[[\"Name\",\"Age\"],[\"John\",30]]'" >&2
  exit 1
fi

# Use batchUpdate endpoint to avoid URL encoding issues with range
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"valueInputOption\": \"USER_ENTERED\",
    \"data\": [{
      \"range\": \"$RANGE\",
      \"majorDimension\": \"ROWS\",
      \"values\": $VALUES
    }]
  }" \
  "https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEET_ID}/values:batchUpdate"
