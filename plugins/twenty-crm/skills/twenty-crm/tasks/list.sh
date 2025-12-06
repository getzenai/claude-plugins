#!/bin/bash
# List tasks with optional filtering, ordering, and pagination
# Usage: list.sh [filter] [order_by] [limit] [depth]
# Example: list.sh 'status[eq]:TODO' 'dueAt[AscNullsLast]' 50
# Example: list.sh 'dueAt[lte]:2024-12-31' '' 100  # Tasks due by end of year
# depth: 0 = basic fields only (default), 1 = include relations

source "$(dirname "$0")/../_auth.sh"

FILTER="$1"
ORDER_BY="$2"
LIMIT="${3:-60}"
DEPTH="${4:-0}"

URL="$BASE_URL/rest/tasks?limit=$LIMIT&depth=$DEPTH"

if [ -n "$FILTER" ]; then
  ENCODED_FILTER=$(printf '%s' "$FILTER" | jq -sRr @uri)
  URL="$URL&filter=$ENCODED_FILTER"
fi

if [ -n "$ORDER_BY" ]; then
  URL="$URL&order_by=$ORDER_BY"
fi

curl -s -H "Authorization: Bearer $API_KEY" "$URL"
