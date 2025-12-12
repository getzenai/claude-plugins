#!/bin/bash
# Update an existing contact
# Usage: update.sh <identifier> '<json_data>'
# Example: update.sh john@example.com '{"attributes":{"FIRSTNAME":"John","LASTNAME":"Smith"}}'
# Example: update.sh 123 '{"listIds":[4,5]}'

source "$(dirname "$0")/../_auth.sh"

IDENTIFIER="$1"
JSON_DATA="$2"

if [ -z "$IDENTIFIER" ] || [ -z "$JSON_DATA" ]; then
  echo "Usage: update.sh <identifier> '<json_data>'" >&2
  echo "" >&2
  echo "identifier: email address or contact ID" >&2
  echo "" >&2
  echo "Updatable fields:" >&2
  echo "  - attributes: Object with contact attributes (FIRSTNAME, LASTNAME, etc.)" >&2
  echo "  - listIds: Array of list IDs (replaces existing lists)" >&2
  echo "  - unlinkListIds: Array of list IDs to remove contact from" >&2
  echo "  - emailBlacklisted: true/false" >&2
  echo "  - smsBlacklisted: true/false" >&2
  echo "" >&2
  echo 'Example: update.sh john@example.com '\''{"attributes":{"FIRSTNAME":"John","LASTNAME":"Smith"}}'\''' >&2
  exit 1
fi

# URL encode the identifier (for email addresses)
ENCODED_ID=$(printf '%s' "$IDENTIFIER" | jq -sRr @uri)

curl -s -X PUT \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/contacts/$ENCODED_ID"
