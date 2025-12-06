#!/bin/bash
# Delete an opportunity by ID
# Usage: delete.sh <opportunity_id>
# Example: delete.sh 20202020-1234-5678-9abc-def012345678

source "$(dirname "$0")/../_auth.sh"

OPPORTUNITY_ID="$1"

if [ -z "$OPPORTUNITY_ID" ]; then
  echo "Usage: delete.sh <opportunity_id>" >&2
  exit 1
fi

curl -s -X DELETE \
  -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/opportunities/$OPPORTUNITY_ID"
