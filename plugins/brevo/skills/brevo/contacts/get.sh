#!/bin/bash
# Get contact details by email or ID
# Usage: get.sh <identifier>
# Example: get.sh john@example.com
# Example: get.sh 123

source "$(dirname "$0")/../_auth.sh"

IDENTIFIER="$1"

if [ -z "$IDENTIFIER" ]; then
  echo "Usage: get.sh <identifier>" >&2
  echo "identifier can be email address or contact ID" >&2
  exit 1
fi

# URL encode the identifier (for email addresses)
ENCODED_ID=$(printf '%s' "$IDENTIFIER" | jq -sRr @uri)

curl -s \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/contacts/$ENCODED_ID"
