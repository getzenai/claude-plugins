#!/bin/bash
# Get details of a specific email campaign
# Usage: get.sh <campaign_id>
# Example: get.sh 123

source "$(dirname "$0")/../_auth.sh"

CAMPAIGN_ID="$1"

if [ -z "$CAMPAIGN_ID" ]; then
  echo "Usage: get.sh <campaign_id>" >&2
  exit 1
fi

curl -s \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  "$BASE_URL/emailCampaigns/$CAMPAIGN_ID"
