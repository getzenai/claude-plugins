#!/bin/bash
# Search calendar events by text
# Usage: search.sh <query> [count] [calendar_id]
# Example: search.sh "meeting"
# Example: search.sh "standup" 20 primary

source "$(dirname "$0")/../_auth.sh"

QUERY="$1"
COUNT="${2:-10}"
CALENDAR_ID="${3:-primary}"

if [ -z "$QUERY" ]; then
  echo "Usage: search.sh <query> [count] [calendar_id]" >&2
  exit 1
fi

ENCODED_QUERY=$(printf '%s' "$QUERY" | jq -sRr @uri)

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events?q=$ENCODED_QUERY&maxResults=$COUNT&orderBy=startTime&singleEvents=true"
