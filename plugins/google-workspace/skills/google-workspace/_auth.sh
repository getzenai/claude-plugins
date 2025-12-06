#!/bin/bash
# Shared auth component - source this from other scripts
# Usage: source "$(dirname "$0")/_auth.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Find skill dir by looking for oauth-app.json
SKILL_DIR="$SCRIPT_DIR"
while [ ! -f "$SKILL_DIR/oauth-app.json" ] && [ "$SKILL_DIR" != "/" ]; do
  SKILL_DIR="$(dirname "$SKILL_DIR")"
done
CREDS_FILE="$HOME/.config/gdrive-skill/credentials.json"

# Check if authenticated
if [ ! -f "$CREDS_FILE" ]; then
  echo "ERROR: Not authenticated. Run setup first." >&2
  exit 1
fi

# Get access token
CLIENT_ID=$(jq -r ".client_id" "$SKILL_DIR/oauth-app.json")
USER_CREDS=$(cat "$CREDS_FILE")
CLIENT_SECRET=$(echo "$USER_CREDS" | jq -r ".client_secret")
REFRESH_TOKEN=$(echo "$USER_CREDS" | jq -r ".refresh_token")

ACCESS_TOKEN=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "grant_type=refresh_token" | jq -r ".access_token")

if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: Failed to get access token. Re-run setup." >&2
  exit 1
fi

export ACCESS_TOKEN
