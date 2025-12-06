#!/bin/bash
# Get a single task by ID (includes taskTargets, assignee)
# Usage: get.sh <task_id>
# Example: get.sh 20202020-1234-5678-9abc-def012345678

source "$(dirname "$0")/../_auth.sh"

TASK_ID="$1"

if [ -z "$TASK_ID" ]; then
  echo "Usage: get.sh <task_id>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/tasks/$TASK_ID?depth=1"
