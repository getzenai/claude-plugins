#!/bin/bash
# Create a new note
# Usage: create.sh '<json_data>'
# Example: create.sh '{"title":"Meeting notes","bodyV2":{"markdown":"# Key points\n- Point 1\n- Point 2"}}'

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo 'Example: create.sh '\''{"title":"Meeting notes","bodyV2":{"markdown":"# Key points"}}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/notes"
