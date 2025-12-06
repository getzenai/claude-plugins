#!/bin/bash
# List recent emails from inbox
# Usage: list.sh [count] [label]
# Example: list.sh 10
# Example: list.sh 10 INBOX

source "$(dirname "$0")/../_auth.sh"

COUNT="${1:-10}"
LABEL="${2:-INBOX}"

# Get message list
MESSAGES=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$COUNT&labelIds=$LABEL")

# Extract message IDs and get details for each
echo "$MESSAGES" | jq -r '.messages[]?.id' | while read -r MSG_ID; do
  if [ -n "$MSG_ID" ]; then
    curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://gmail.googleapis.com/gmail/v1/users/me/messages/$MSG_ID?format=metadata&metadataHeaders=Subject&metadataHeaders=From&metadataHeaders=Date" | \
      jq '{id: .id, snippet: .snippet, headers: [.payload.headers[] | {(.name): .value}] | add}'
  fi
done | jq -s '.'
