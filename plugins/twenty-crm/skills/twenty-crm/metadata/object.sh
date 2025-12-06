#!/bin/bash
# Get metadata for a specific object type including all fields
# Usage: object.sh <object_id>
# Example: object.sh 20202020-1c25-4d02-bf25-6aeccf7ea419

source "$(dirname "$0")/../_auth.sh"

OBJECT_ID="$1"

if [ -z "$OBJECT_ID" ]; then
  echo "Usage: object.sh <object_id>" >&2
  echo "Get object ID from objects.sh first" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/metadata/objects/$OBJECT_ID"
