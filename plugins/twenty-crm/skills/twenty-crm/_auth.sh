#!/bin/bash
# Shared authentication component for Twenty CRM API
# Sources config and exports BASE_URL and API_KEY

CONFIG_FILE="$HOME/.config/twenty-crm/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Twenty CRM config not found at $CONFIG_FILE" >&2
  echo "Please create it with your base_url and api_key. See config.json.example for format." >&2
  exit 1
fi

export BASE_URL=$(jq -r '.base_url' "$CONFIG_FILE")
export API_KEY=$(jq -r '.api_key' "$CONFIG_FILE")

if [ -z "$BASE_URL" ] || [ "$BASE_URL" = "null" ]; then
  echo "Error: base_url not found in $CONFIG_FILE" >&2
  exit 1
fi

if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
  echo "Error: api_key not found in $CONFIG_FILE" >&2
  exit 1
fi

# Remove trailing slash from BASE_URL if present
export BASE_URL="${BASE_URL%/}"
