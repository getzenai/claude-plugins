#!/bin/bash
# Get details of a specific list
# Usage: get.sh <list_id>
# Example: get.sh 4

source "$(dirname "$0")/../_auth.sh"

LIST_ID="$1"

if [ -z "$LIST_ID" ]; then
  echo "Usage: get.sh <list_id>" >&2
  exit 1
fi

curl -s \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/contacts/lists/$LIST_ID"
