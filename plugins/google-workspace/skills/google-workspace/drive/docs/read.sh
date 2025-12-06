#!/bin/bash
# Read content from a Google Doc
# Usage: read.sh <doc_id>
# Example: read.sh 1abc123xyz

source "$(dirname "$0")/../../_auth.sh"

DOC_ID="$1"

if [ -z "$DOC_ID" ]; then
  echo "Usage: read.sh <doc_id>" >&2
  exit 1
fi

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://docs.googleapis.com/v1/documents/$DOC_ID"
