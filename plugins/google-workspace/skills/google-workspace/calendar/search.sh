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

# Search past events (up to now), fetch more to allow getting recent ones, then return most recent first
TIME_MAX=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Fetch up to 250 results (API max per page) to get recent matches, then take last N
FETCH_COUNT=250

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/$CALENDAR_ID/events?q=$ENCODED_QUERY&maxResults=$FETCH_COUNT&timeMax=$TIME_MAX&singleEvents=true&orderBy=startTime" | \
  jq --argjson count "$COUNT" '{events: [.items[] | {id, summary, description, start: (.start.dateTime // .start.date), end: (.end.dateTime // .end.date), location, link: .htmlLink, attendees: [.attendees[]? | {email, status: .responseStatus}]}] | .[-$count:] | reverse} // .'
