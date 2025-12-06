#!/bin/bash
# Update an existing person
# Usage: update.sh <person_id> '<json_data>'
# Example: update.sh 20202020-1234-5678-9abc-def012345678 '{"jobTitle":"Senior Engineer"}'

source "$(dirname "$0")/../_auth.sh"

PERSON_ID="$1"
JSON_DATA="$2"

if [ -z "$PERSON_ID" ] || [ -z "$JSON_DATA" ]; then
  echo "Usage: update.sh <person_id> '<json_data>'" >&2
  exit 1
fi

curl -s -X PATCH \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/people/$PERSON_ID"
