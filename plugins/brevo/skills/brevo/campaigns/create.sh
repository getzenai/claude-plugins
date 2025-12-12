#!/bin/bash
# Create a new email campaign (as draft by default)
# Usage: create.sh '<json_data>'
# Example: create.sh '{"name":"Newsletter","subject":"Weekly Update","sender":{"name":"Company","email":"news@example.com"},"htmlContent":"<html><body>Content</body></html>","recipients":{"listIds":[4]}}'

source "$(dirname "$0")/../_auth.sh"

JSON_DATA="$1"

if [ -z "$JSON_DATA" ]; then
  echo "Usage: create.sh '<json_data>'" >&2
  echo "" >&2
  echo "Required fields:" >&2
  echo "  - name: Campaign name" >&2
  echo "  - subject: Email subject line" >&2
  echo "  - sender: {name, email}" >&2
  echo "  - htmlContent: HTML body of the email" >&2
  echo "  - recipients: {listIds: [id1, id2, ...]}" >&2
  echo "" >&2
  echo 'Example: create.sh '\''{"name":"Newsletter","subject":"Weekly Update","sender":{"name":"Company","email":"news@example.com"},"htmlContent":"<html><body>Hello!</body></html>","recipients":{"listIds":[4]}}'\''' >&2
  exit 1
fi

curl -s -X POST \
  -H "api-key: $API_KEY" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -d "$JSON_DATA" \
  "$BASE_URL/emailCampaigns"
