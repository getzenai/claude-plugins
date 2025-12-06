#!/bin/bash
# Delete a task by ID
# Usage: delete.sh <task_id>
# Example: delete.sh 20202020-1234-5678-9abc-def012345678

source "$(dirname "$0")/../_auth.sh"

TASK_ID="$1"

if [ -z "$TASK_ID" ]; then
  echo "Usage: delete.sh <task_id>" >&2
  exit 1
fi

curl -s -X DELETE \
  -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/tasks/$TASK_ID"
