#!/bin/bash
# List workspace members
# Usage: list.sh [limit]
# Example: list.sh 20

source "$(dirname "$0")/../_auth.sh"

LIMIT="${1:-20}"

curl -s -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/workspaceMembers?limit=$LIMIT"
