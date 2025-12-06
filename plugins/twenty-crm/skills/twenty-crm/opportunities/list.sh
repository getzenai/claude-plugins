#!/bin/bash
# List opportunities with optional filtering, ordering, and pagination
# Usage: list.sh [filter] [order_by] [limit] [depth]
# Example: list.sh 'stage[eq]:NEW_LEAD' 'createdAt[DescNullsLast]' 50
# Example: list.sh 'ownerV2Id[is]:NULL' '' 100  # Find unowned opportunities
# depth: 0 = basic fields only (default), 1 = include relations

source "$(dirname "$0")/../_auth.sh"

FILTER="$1"
ORDER_BY="$2"
LIMIT="${3:-60}"
DEPTH="${4:-0}"

URL="$BASE_URL/rest/opportunities?limit=$LIMIT&depth=$DEPTH"

if [ -n "$FILTER" ]; then
  ENCODED_FILTER=$(printf '%s' "$FILTER" | jq -sRr @uri)
  URL="$URL&filter=$ENCODED_FILTER"
fi

if [ -n "$ORDER_BY" ]; then
  URL="$URL&order_by=$ORDER_BY"
fi

curl -s -H "Authorization: Bearer $API_KEY" "$URL"
