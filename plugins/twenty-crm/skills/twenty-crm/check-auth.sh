#!/bin/bash
# Check if Twenty CRM authentication is configured
# Returns USER_AUTHENTICATED or USER_NOT_AUTHENTICATED

CONFIG_FILE="$HOME/.config/twenty-crm/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "USER_NOT_AUTHENTICATED"
  exit 0
fi

BASE_URL=$(jq -r '.base_url' "$CONFIG_FILE" 2>/dev/null)
API_KEY=$(jq -r '.api_key' "$CONFIG_FILE" 2>/dev/null)

if [ -z "$BASE_URL" ] || [ "$BASE_URL" = "null" ] || [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
  echo "USER_NOT_AUTHENTICATED"
  exit 0
fi

# Test the API connection by fetching people (core API)
BASE_URL="${BASE_URL%/}"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $API_KEY" "$BASE_URL/rest/people?limit=1")

if [ "$RESPONSE" = "200" ]; then
  echo "USER_AUTHENTICATED"
else
  echo "USER_NOT_AUTHENTICATED"
fi
