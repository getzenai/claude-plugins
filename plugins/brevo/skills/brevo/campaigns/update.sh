#!/bin/bash
# Update an existing email campaign (draft)
# Usage: update.sh <campaign_id> '<json_data>'
# Example: update.sh 123 '{"subject":"New Subject","htmlContent":"<html><body>Updated content</body></html>"}'

source "$(dirname "$0")/../_auth.sh"

CAMPAIGN_ID="$1"
JSON_DATA="$2"

if [ -z "$CAMPAIGN_ID" ] || [ -z "$JSON_DATA" ]; then
  echo "Usage: update.sh <campaign_id> '<json_data>'" >&2
  echo "" >&2
  echo "Updatable fields:" >&2
  echo "  - name: Campaign name" >&2
  echo "  - subject: Email subject line" >&2
  echo "  - sender: {name, email}" >&2
  echo "  - htmlContent: HTML body of the email" >&2
  echo "  - recipients: {listIds: [id1, id2, ...]}" >&2
  echo "" >&2
  echo 'Example: update.sh 123 '\''{"subject":"Updated Subject","htmlContent":"<html><body>New content here</body></html>"}'\''' >&2
  exit 1
fi

curl -s -X PUT \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/emailCampaigns/$CAMPAIGN_ID"
