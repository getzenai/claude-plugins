#!/bin/bash
# List all email templates
# Usage: list.sh [limit] [offset]
# Example: list.sh 50 0

source "$(dirname "$0")/../_auth.sh"

LIMIT="${1:-50}"
OFFSET="${2:-0}"

curl -s \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/smtp/templates?limit=$LIMIT&offset=$OFFSET"
