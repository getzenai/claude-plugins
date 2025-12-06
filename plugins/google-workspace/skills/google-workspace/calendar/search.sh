#!/bin/bash
# Search calendar events by text
# Usage: search.sh <query> [count] [time_min] [time_max] [calendar_id]
# Example: search.sh "meeting"
# Example: search.sh "meeting" 10 2024-08-01 2024-08-31
# Example: search.sh "standup" 20 "" "" primary

source "$(dirname "$0")/../_auth.sh"

QUERY="$1"
COUNT="${2:-10}"
TIME_MIN="$3"
TIME_MAX="$4"
CALENDAR_ID="${5:-primary}"

if [ -z "$QUERY" ]; then
  echo "Usage: search.sh <query> [count] [time_min] [time_max] [calendar_id]" >&2
  echo "  time_min/time_max: date or datetime (e.g., 2024-08-01 or 2024-08-01T00:00:00)" >&2
  exit 1
fi

ENCODED_QUERY=$(printf '%s' "$QUERY" | jq -sRr @uri)

# Build URL with optional time filters
URL="https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events?q=$ENCODED_QUERY&maxResults=$COUNT&orderBy=updated&singleEvents=true"

if [ -n "$TIME_MIN" ]; then
  # Append T00:00:00Z if only date provided
  [[ "$TIME_MIN" == *T* ]] || TIME_MIN="${TIME_MIN}T00:00:00Z"
  URL="${URL}&timeMin=$TIME_MIN"
fi

if [ -n "$TIME_MAX" ]; then
  # Append T23:59:59Z if only date provided
  [[ "$TIME_MAX" == *T* ]] || TIME_MAX="${TIME_MAX}T23:59:59Z"
  URL="${URL}&timeMax=$TIME_MAX"
fi

# Order by updated time (most recently modified first)
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$URL" | \
  jq '{events: [.items[] | {id, summary, description, start: (.start.dateTime // .start.date), end: (.end.dateTime // .end.date), location, link: .htmlLink, attendees: [.attendees[]? | {email, status: .responseStatus}]}] | reverse} // .'
