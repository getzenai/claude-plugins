#!/bin/bash
# Get a specific calendar event
# Usage: get.sh <event_id> [calendar_id]
# Example: get.sh abc123xyz
# Example: get.sh abc123xyz primary

source "$(dirname "$0")/../_auth.sh"

EVENT_ID="$1"
CALENDAR_ID="${2:-primary}"

if [ -z "$EVENT_ID" ]; then
  echo "Usage: get.sh <event_id> [calendar_id]" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events/$EVENT_ID"
