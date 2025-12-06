#!/bin/bash
# Read a Google Slides presentation
# Usage: read.sh <presentation_id>
# Example: read.sh 1abc123xyz

source "$(dirname "$0")/../../_auth.sh"

PRESENTATION_ID="$1"

if [ -z "$PRESENTATION_ID" ]; then
  echo "Usage: read.sh <presentation_id>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://slides.googleapis.com/v1/presentations/$PRESENTATION_ID"
