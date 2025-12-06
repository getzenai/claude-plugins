#!/bin/bash
# Link a task to an opportunity, person, or company via taskTargets
# Usage: link.sh <task_id> <target_type> <target_id>
# target_type: opportunity, person, or company
# Example: link.sh <task-id> opportunity <opportunity-id>
# Example: link.sh <task-id> person <person-id>

source "$(dirname "$0")/../_auth.sh"

TASK_ID="$1"
TARGET_TYPE="$2"
TARGET_ID="$3"

if [ -z "$TASK_ID" ] || [ -z "$TARGET_TYPE" ] || [ -z "$TARGET_ID" ]; then
  echo "Usage: link.sh <task_id> <target_type> <target_id>" >&2
  echo "target_type: opportunity, person, or company" >&2
  exit 1
fi

case "$TARGET_TYPE" in
  opportunity)
    JSON_DATA="{\"taskId\":\"$TASK_ID\",\"opportunityId\":\"$TARGET_ID\"}"
    ;;
  person)
    JSON_DATA="{\"taskId\":\"$TASK_ID\",\"personId\":\"$TARGET_ID\"}"
    ;;
  company)
    JSON_DATA="{\"taskId\":\"$TASK_ID\",\"companyId\":\"$TARGET_ID\"}"
    ;;
  *)
    echo "Error: target_type must be 'opportunity', 'person', or 'company'" >&2
    exit 1
    ;;
esac

curl -s -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/taskTargets"
