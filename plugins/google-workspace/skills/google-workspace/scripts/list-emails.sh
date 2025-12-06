#!/bin/bash
# List recent emails from Gmail
# Usage: list-emails.sh [count] [query]
# Example: list-emails.sh 10
# Example: list-emails.sh 5 "from:someone@example.com"

source "$(dirname "$0")/_auth.sh"

COUNT="${1:-10}"
QUERY="${2:-}"

if [ -n "$QUERY" ]; then
  ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)
  curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$COUNT&q=$ENCODED_QUERY"
else
  curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$COUNT"
fi
