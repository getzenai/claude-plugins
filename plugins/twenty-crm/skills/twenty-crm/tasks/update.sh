#!/bin/bash
# Update an existing task
# Usage: update.sh <task_id> '<json_data>'
# Example: update.sh 20202020-1234-5678-9abc-def012345678 '{"status":"DONE"}'

source "$(dirname "$0")/../_auth.sh"

TASK_ID="$1"
JSON_DATA="$2"

if [ -z "$TASK_ID" ] || [ -z "$JSON_DATA" ]; then
  echo "Usage: update.sh <task_id> '<json_data>'" >&2
  exit 1
fi

curl -s -X PATCH \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/tasks/$TASK_ID"
