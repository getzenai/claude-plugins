#!/bin/bash
# Get details of a specific email template
# Usage: get.sh <template_id>
# Example: get.sh 1

source "$(dirname "$0")/../_auth.sh"

TEMPLATE_ID="$1"

if [ -z "$TEMPLATE_ID" ]; then
  echo "Usage: get.sh <template_id>" >&2
  exit 1
fi

curl -s \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/smtp/templates/$TEMPLATE_ID"
