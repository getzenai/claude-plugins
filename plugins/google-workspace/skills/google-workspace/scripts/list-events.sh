#!/bin/bash
# List upcoming calendar events
# Usage: list-events.sh [count]

source "$(dirname "$0")/_auth.sh"

COUNT="${1:-10}"
TIME_MIN=$(date -u +%Y-%m-%dT%H:%M:%SZ)

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/primary/events?maxResults=$COUNT&orderBy=startTime&singleEvents=true&timeMin=$TIME_MIN"
