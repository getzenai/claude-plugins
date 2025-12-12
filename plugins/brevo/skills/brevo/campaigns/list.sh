#!/bin/bash
# List all email campaigns
# Usage: list.sh [type] [status] [limit] [offset]
# type: classic, trigger (default: all)
# status: draft, sent, queued, suspended, in_process, archive (default: all)
# Example: list.sh classic draft 50 0

source "$(dirname "$0")/../_auth.sh"

TYPE="$1"
STATUS="$2"
LIMIT="${3:-50}"
OFFSET="${4:-0}"

URL="$BASE_URL/emailCampaigns?limit=$LIMIT&offset=$OFFSET"

if [ -n "$TYPE" ]; then
  URL="$URL&type=$TYPE"
fi

if [ -n "$STATUS" ]; then
  URL="$URL&status=$STATUS"
fi

curl -s \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$URL"
