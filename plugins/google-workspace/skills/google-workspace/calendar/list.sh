#!/bin/bash
# List upcoming calendar events
# Usage: list.sh [count] [calendar_id]
# Example: list.sh 10
# Example: list.sh 10 primary

source "$(dirname "$0")/../_auth.sh"

COUNT="${1:-10}"
CALENDAR_ID="${2:-primary}"

# Get events from now onwards
TIME_MIN=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events?maxResults=$COUNT&timeMin=$TIME_MIN&orderBy=startTime&singleEvents=true"
