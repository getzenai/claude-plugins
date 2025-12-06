#!/bin/bash
# Delete a calendar event
# Usage: delete.sh <event_id> [calendar_id]
# Example: delete.sh abc123xyz
# Example: delete.sh abc123xyz primary

source "$(dirname "$0")/../_auth.sh"

EVENT_ID="$1"
CALENDAR_ID="${2:-primary}"

if [ -z "$EVENT_ID" ]; then
  echo "Usage: delete.sh <event_id> [calendar_id]" >&2
  exit 1
fi

curl -s -X DELETE -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events/$EVENT_ID"

echo "Event deleted: $EVENT_ID"
