#!/bin/bash
# Read an email from Gmail
# Usage: read-email.sh <message_id>

source "$(dirname "$0")/_auth.sh"

MESSAGE_ID="$1"
if [ -z "$MESSAGE_ID" ]; then
  echo "Usage: read-email.sh <message_id>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages/$MESSAGE_ID?format=full"
