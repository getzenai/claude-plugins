#!/bin/bash
# Create a new calendar event
# Usage: create.sh <summary> <start_datetime> <end_datetime> [description] [calendar_id]
# Example: create.sh "Team Meeting" "2024-01-15T10:00:00" "2024-01-15T11:00:00"
# Example: create.sh "Team Meeting" "2024-01-15T10:00:00" "2024-01-15T11:00:00" "Weekly sync" primary

source "$(dirname "$0")/../_auth.sh"

SUMMARY="$1"
START_DATETIME="$2"
END_DATETIME="$3"
DESCRIPTION="${4:-}"
CALENDAR_ID="${5:-primary}"

if [ -z "$SUMMARY" ] || [ -z "$START_DATETIME" ] || [ -z "$END_DATETIME" ]; then
  echo "Usage: create.sh <summary> <start_datetime> <end_datetime> [description] [calendar_id]" >&2
  echo "Example: create.sh \"Team Meeting\" \"2024-01-15T10:00:00\" \"2024-01-15T11:00:00\"" >&2
  exit 1
fi

# Get local timezone
TIMEZONE=$(date +%Z)

if [ -n "$DESCRIPTION" ]; then
  EVENT_JSON="{
    \"summary\": \"$SUMMARY\",
    \"description\": \"$DESCRIPTION\",
    \"start\": {
      \"dateTime\": \"$START_DATETIME\",
      \"timeZone\": \"$TIMEZONE\"
    },
    \"end\": {
      \"dateTime\": \"$END_DATETIME\",
      \"timeZone\": \"$TIMEZONE\"
    }
  }"
else
  EVENT_JSON="{
    \"summary\": \"$SUMMARY\",
    \"start\": {
      \"dateTime\": \"$START_DATETIME\",
      \"timeZone\": \"$TIMEZONE\"
    },
    \"end\": {
      \"dateTime\": \"$END_DATETIME\",
      \"timeZone\": \"$TIMEZONE\"
    }
  }"
fi

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$EVENT_JSON" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events"
