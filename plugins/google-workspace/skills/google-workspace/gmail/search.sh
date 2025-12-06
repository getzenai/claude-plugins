#!/bin/bash
# Search emails
# Usage: search.sh <query> [count]
# Example: search.sh "from:john@example.com"
# Example: search.sh "subject:invoice" 20
# Query syntax: https://support.google.com/mail/answer/7190

source "$(dirname "$0")/../_auth.sh"

QUERY="$1"
COUNT="${2:-10}"

if [ -z "$QUERY" ]; then
  echo "Usage: search.sh <query> [count]" >&2
  echo "Example: search.sh \"from:john@example.com\"" >&2
  exit 1
fi

ENCODED_QUERY=$(printf '%s' "$QUERY" | jq -sRr @uri)

# Get message list
MESSAGES=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$COUNT&q=$ENCODED_QUERY")

# Extract message IDs and get details for each
echo "$MESSAGES" | jq -r '.messages[]?.id' | while read -r MSG_ID; do
  if [ -n "$MSG_ID" ]; then
    curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://gmail.googleapis.com/gmail/v1/users/me/messages/$MSG_ID?format=metadata&metadataHeaders=Subject&metadataHeaders=From&metadataHeaders=Date" | \
      jq '{id: .id, snippet: .snippet, headers: [.payload.headers[] | {(.name): .value}] | add}'
  fi
done | jq -s '.'
