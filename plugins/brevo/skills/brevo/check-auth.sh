#!/bin/bash
# Check if user is authenticated with Brevo API

CONFIG_FILE="$HOME/.config/brevo/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "USER_NOT_AUTHENTICATED"
  exit 0
fi

API_KEY=$(jq -r '.api_key' "$CONFIG_FILE" 2>/dev/null)

if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
  echo "USER_NOT_AUTHENTICATED"
  exit 0
fi

# Test the API connection by fetching account info
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "api-key: $API_KEY" \
  "https://api.brevo.com/v3/account")

if [ "$RESPONSE" = "200" ]; then
  echo "USER_AUTHENTICATED"
else
  echo "USER_NOT_AUTHENTICATED"
fi
