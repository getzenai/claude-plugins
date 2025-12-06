#!/bin/bash
# Create a new person
# Usage: create.sh '<json_data>'
# Example: create.sh '{"name":{"firstName":"John","lastName":"Doe"},"emails":{"primaryEmail":"john@example.com"}}'

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo 'Example: create.sh '\''{"name":{"firstName":"John","lastName":"Doe"},"emails":{"primaryEmail":"john@example.com"}}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/rest/people"
