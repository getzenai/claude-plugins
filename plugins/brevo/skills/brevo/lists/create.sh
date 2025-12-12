#!/bin/bash
# Create a new contact list
# Usage: create.sh '<json_data>'
# Example: create.sh '{"name":"My Newsletter","folderId":1}'

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo "" >&2
  echo "Required fields:" >&2
  echo "  - name: Name of the list" >&2
  echo "  - folderId: ID of the folder to create the list in" >&2
  echo "" >&2
  echo 'Example: create.sh '\''{"name":"My Newsletter","folderId":1}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/contacts/lists"
