#!/bin/bash
# Create a calendar event
# Usage: create-event.sh <summary> <start_datetime> <end_datetime> [description]
# Example: create-event.sh "Team Meeting" "2024-12-10T10:00:00" "2024-12-10T11:00:00" "Weekly sync"
# Note: datetimes should be in ISO format (YYYY-MM-DDTHH:MM:SS)

source "$(dirname "$0")/_auth.sh"

SUMMARY="$1"
START="$2"
END="$3"
DESCRIPTION="${4:-}"

if [ -z "$SUMMARY" ] || [ -z "$START" ] || [ -z "$END" ]; then
  echo "Usage: create-event.sh <summary> <start_datetime> <end_datetime> [description]" >&2
  echo "Example: create-event.sh \"Team Meeting\" \"2024-12-10T10:00:00\" \"2024-12-10T11:00:00\"" >&2
  exit 1
fi

# Get local timezone
TZ=$(date +%Z)

JSON=$(cat <<EOF
{
  "summary": "$SUMMARY",
  "description": "$DESCRIPTION",
  "start": {"dateTime": "$START", "timeZone": "$TZ"},
  "end": {"dateTime": "$END", "timeZone": "$TZ"}
}
EOF
)

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$JSON" \
  "https://www.googleapis.com/calendar/v3/calendars/primary/events"
