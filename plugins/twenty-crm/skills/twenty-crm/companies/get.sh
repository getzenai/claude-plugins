#!/bin/bash
# Get a single company by ID
# Usage: get.sh <company_id>
# Example: get.sh 20202020-1234-5678-9abc-def012345678

source "$(dirname "$0")/../_auth.sh"

COMPANY_ID="$1"

if [ -z "$COMPANY_ID" ]; then
  echo "Usage: get.sh <company_id>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/companies/$COMPANY_ID?depth=1"
