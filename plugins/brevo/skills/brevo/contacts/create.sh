#!/bin/bash
# Create a new contact (optionally add to lists)
# Usage: create.sh '<json_data>'
# Example: create.sh '{"email":"john@example.com","attributes":{"FIRSTNAME":"John","LASTNAME":"Doe"},"listIds":[4],"updateEnabled":true}'

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo 'Example: create.sh '\''{"email":"john@example.com","attributes":{"FIRSTNAME":"John","LASTNAME":"Doe"},"listIds":[4],"updateEnabled":true}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/contacts"
