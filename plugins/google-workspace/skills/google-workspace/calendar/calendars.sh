#!/bin/bash
# List all available calendars
# Usage: calendars.sh

source "$(dirname "$0")/../_auth.sh"

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/users/me/calendarList"
