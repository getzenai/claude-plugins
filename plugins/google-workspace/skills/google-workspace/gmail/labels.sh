#!/bin/bash
# List all Gmail labels
# Usage: labels.sh

source "$(dirname "$0")/../_auth.sh"

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/labels"
