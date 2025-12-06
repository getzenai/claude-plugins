#!/bin/bash
# Create a new opportunity
# Usage: create.sh '<json_data>'
# Example: create.sh '{"name":"New Deal","stage":"QUALIFICATION","pointOfContactId":"<person-id>"}'
# Stages: NEW_LEAD, QUALIFICATION, IN_TEST_PHASE, PROPOSAL_NEGOTIATION, CUSTOMER, AFTERSALES, DROP_OUT, WANTS_FEATURE

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo 'Example: create.sh '\''{"name":"New Deal","stage":"QUALIFICATION","pointOfContactId":"<person-id>"}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/opportunities"
