#!/bin/bash
# Delete an email campaign
# Usage: delete.sh <campaign_id>
# Example: delete.sh 123

source "$(dirname "$0")/../_auth.sh"

CAMPAIGN_ID="$1"

if [ -z "$CAMPAIGN_ID" ]; then
  echo "Usage: delete.sh <campaign_id>" >&2
  exit 1
fi

curl -s -X DELETE \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/emailCampaigns/$CAMPAIGN_ID"
