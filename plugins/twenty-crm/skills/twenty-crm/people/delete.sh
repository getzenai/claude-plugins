#!/bin/bash
# Delete a person by ID
# Usage: delete.sh <person_id>
# Example: delete.sh 20202020-1234-5678-9abc-def012345678

source "$(dirname "$0")/../_auth.sh"

PERSON_ID="$1"

if [ -z "$PERSON_ID" ]; then
  echo "Usage: delete.sh <person_id>" >&2
  exit 1
fi

curl -s -X DELETE \
  -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/people/$PERSON_ID"
