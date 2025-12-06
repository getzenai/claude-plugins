#!/bin/bash
# Get the current user's workspace member info from the API token
# Usage: me.sh
# Returns the workspace member associated with the API key

source "$(dirname "$0")/../_auth.sh"

# Extract workspace member ID from JWT token (it's in the 'sub' claim)
# JWT format: header.payload.signature
PAYLOAD=$(echo "$API_KEY" | cut -d'.' -f2)

# Add padding if needed for base64 decoding
PADDING=$((4 - ${#PAYLOAD} % 4))
if [ $PADDING -ne 4 ]; then
  PAYLOAD="${PAYLOAD}$(printf '=%.0s' $(seq 1 $PADDING))"
fi

# Decode and extract the workspaceId (sub claim contains workspace ID for API keys)
WORKSPACE_ID=$(echo "$PAYLOAD" | base64 -d 2>/dev/null | jq -r '.sub // .workspaceId // empty')

if [ -z "$WORKSPACE_ID" ]; then
  echo '{"error": "Could not extract workspace ID from token"}' >&2
  exit 1
fi

# For API keys, the 'sub' is the workspace ID, not the user
# We need to get all workspace members and identify the current one differently
# Since API keys don't directly identify a user, list all members
curl -s -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/rest/workspaceMembers?limit=50" | jq '.data.workspaceMembers[] | {id, name, userEmail}'
