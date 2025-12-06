#!/bin/bash
# Update a calendar event
# Usage: update.sh <event_id> <json_updates> [calendar_id]
# Example: update.sh abc123xyz '{"summary": "Updated Meeting Title"}'
# Example: update.sh abc123xyz '{"description": "New description"}' primary

source "$(dirname "$0")/../_auth.sh"

EVENT_ID="$1"
UPDATES="$2"
CALENDAR_ID="${3:-primary}"

if [ -z "$EVENT_ID" ] || [ -z "$UPDATES" ]; then
  echo "Usage: update.sh <event_id> <json_updates> [calendar_id]" >&2
  echo "Example: update.sh abc123xyz '{\"summary\": \"Updated Meeting Title\"}'" >&2
  exit 1
fi

curl -s -X PATCH -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$UPDATES" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events/$EVENT_ID"
