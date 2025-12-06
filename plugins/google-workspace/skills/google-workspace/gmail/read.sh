#!/bin/bash
# Read a specific email
# Usage: read.sh <message_id> [format]
# Example: read.sh abc123xyz
# Example: read.sh abc123xyz full
# Formats: full, metadata, minimal, raw

source "$(dirname "$0")/../_auth.sh"

MESSAGE_ID="$1"
FORMAT="${2:-full}"

if [ -z "$MESSAGE_ID" ]; then
  echo "Usage: read.sh <message_id> [format]" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages/$MESSAGE_ID?format=$FORMAT"
