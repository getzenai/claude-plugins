#!/bin/bash
# Check if user is authenticated with Google Workspace
# Usage: check-auth.sh

CREDS_FILE="$HOME/.config/gdrive-skill/credentials.json"

if [ -f "$CREDS_FILE" ]; then
  echo "USER_AUTHENTICATED"
else
  echo "USER_NOT_AUTHENTICATED"
fi
