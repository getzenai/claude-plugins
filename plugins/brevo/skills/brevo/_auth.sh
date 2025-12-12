#!/bin/bash
# Shared authentication component for Brevo API
# Sources config and exports BASE_URL and API_KEY

CONFIG_FILE="$HOME/.config/brevo/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Brevo config not found at $CONFIG_FILE" >&2
  echo "Please create it with your api_key. See config.json.example for format." >&2
  exit 1
fi

export API_KEY=$(jq -r '.api_key' "$CONFIG_FILE")
export BASE_URL="https://api.brevo.com/v3"

if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
  echo "Error: api_key not found in $CONFIG_FILE" >&2
  exit 1
fi
