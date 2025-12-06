#!/bin/bash
# Create a new task
# Usage: create.sh '<json_data>'
# Example: create.sh '{"title":"Follow up call","status":"TODO","dueAt":"2024-12-20T10:00:00Z"}'
# Statuses: TODO, IN_PROGRESS, DONE

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo 'Example: create.sh '\''{"title":"Follow up call","status":"TODO","dueAt":"2024-12-20T10:00:00Z"}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/tasks"
