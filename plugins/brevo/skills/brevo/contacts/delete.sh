#!/bin/bash
# Delete a contact
# Usage: delete.sh <identifier>
# Example: delete.sh john@example.com
# Example: delete.sh 123

source "$(dirname "$0")/../_auth.sh"

IDENTIFIER="$1"

if [ -z "$IDENTIFIER" ]; then
  echo "Usage: delete.sh <identifier>" >&2
  echo "identifier: email address or contact ID" >&2
  exit 1
fi

# URL encode the identifier (for email addresses)
ENCODED_ID=$(printf '%s' "$IDENTIFIER" | jq -sRr @uri)

curl -s -X DELETE \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/contacts/$ENCODED_ID"
