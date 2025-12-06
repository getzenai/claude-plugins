#!/bin/bash
# Delete a note by ID
# Usage: delete.sh <note_id>
# Example: delete.sh 20202020-1234-5678-9abc-def012345678

source "$(dirname "$0")/../_auth.sh"

NOTE_ID="$1"

if [ -z "$NOTE_ID" ]; then
  echo "Usage: delete.sh <note_id>" >&2
  exit 1
fi

curl -s -X DELETE \
  -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/notes/$NOTE_ID"
