#!/bin/bash
# Read a specific email
# Usage: read.sh <message_id> [format] [--all-headers]
# Example: read.sh abc123xyz
# Example: read.sh abc123xyz full
# Example: read.sh abc123xyz full --all-headers
# Formats: full, metadata, minimal, raw
# Options:
#   --all-headers  Include all headers (default filters to essential headers only)

source "$(dirname "$0")/../_auth.sh"

MESSAGE_ID=""
FORMAT="full"
ALL_HEADERS=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --all-headers)
      ALL_HEADERS=true
      ;;
    *)
      if [ -z "$MESSAGE_ID" ]; then
        MESSAGE_ID="$arg"
      elif [ "$FORMAT" = "full" ]; then
        FORMAT="$arg"
      fi
      ;;
  esac
done

if [ -z "$MESSAGE_ID" ]; then
  echo "Usage: read.sh <message_id> [format] [--all-headers]" >&2
  exit 1
fi

RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages/$MESSAGE_ID?format=$FORMAT")

if [ "$ALL_HEADERS" = true ]; then
  echo "$RESPONSE"
else
  # Filter to keep only essential headers
  echo "$RESPONSE" | jq '
    if .payload.headers then
      .payload.headers |= map(select(.name | test("^(From|To|Cc|Bcc|Subject|Date|Reply-To|Message-ID|In-Reply-To|References)$"; "i")))
    else
      .
    end
  '
fi
