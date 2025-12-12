#!/bin/bash
# Delete a contact list
# Usage: delete.sh <list_id>
# Example: delete.sh 4
# Note: Deleting a list does not delete the contacts in it

source "$(dirname "$0")/../_auth.sh"

LIST_ID="$1"

if [ -z "$LIST_ID" ]; then
  echo "Usage: delete.sh <list_id>" >&2
  echo "Note: Deleting a list does not delete the contacts in it" >&2
  exit 1
fi

curl -s -X DELETE \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/contacts/lists/$LIST_ID"
