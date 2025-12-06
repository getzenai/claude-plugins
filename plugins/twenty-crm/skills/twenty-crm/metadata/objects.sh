#!/bin/bash
# List all object types and their metadata (fields, relationships)
# Usage: objects.sh [limit]
# Example: objects.sh 100

source "$(dirname "$0")/../_auth.sh"

LIMIT="${1:-100}"

curl -s -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/metadata/objects?limit=$LIMIT"
