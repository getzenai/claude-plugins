#!/bin/bash
# List companies with optional filtering, ordering, and pagination
# Usage: list.sh [filter] [order_by] [limit] [depth]
# Example: list.sh 'name[ilike]:%Tech%' 'createdAt[DescNullsLast]' 50
# depth: 0 = basic fields only (default), 1 = include relations

source "$(dirname "$0")/../_auth.sh"

FILTER="$1"
ORDER_BY="$2"
LIMIT="${3:-60}"
DEPTH="${4:-0}"

URL="$BASE_URL/rest/companies?limit=$LIMIT&depth=$DEPTH"

if [ -n "$FILTER" ]; then
  ENCODED_FILTER=$(printf '%s' "$FILTER" | jq -sRr @uri)
  URL="$URL&filter=$ENCODED_FILTER"
fi

if [ -n "$ORDER_BY" ]; then
  URL="$URL&order_by=$ORDER_BY"
fi

curl -s -H "Authorization: Bearer $API_KEY" "$URL"
