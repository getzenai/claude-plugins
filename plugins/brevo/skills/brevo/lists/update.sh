#!/bin/bash
# Update an existing contact list
# Usage: update.sh <list_id> '<json_data>'
# Example: update.sh 4 '{"name":"Updated Newsletter Name"}'

source "$(dirname "$0")/../_auth.sh"

LIST_ID="$1"
JSON_DATA="$2"

if [ -z "$LIST_ID" ] || [ -z "$JSON_DATA" ]; then
  echo "Usage: update.sh <list_id> '<json_data>'" >&2
  echo "" >&2
  echo "Updatable fields:" >&2
  echo "  - name: Name of the list" >&2
  echo "  - folderId: ID of the folder to move the list to" >&2
  echo "" >&2
  echo 'Example: update.sh 4 '\''{"name":"Updated Newsletter Name"}'\''' >&2
  exit 1
fi

curl -s -X PUT \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/contacts/lists/$LIST_ID"
