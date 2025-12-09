#!/bin/bash
# Read content from a Google Doc with tab support
# Usage: read.sh <doc_id> [options]
#
# Options:
#   --list-tabs       List available tabs in the document
#   --tab <name>      Read a specific tab by name
#   --tab-index <n>   Read a specific tab by index (0-based)
#   --all-tabs        Read content from all tabs
#
# Examples:
#   read.sh 1abc123xyz                    # Read first tab (default behavior)
#   read.sh 1abc123xyz --list-tabs        # List all tabs
#   read.sh 1abc123xyz --tab "Transcript" # Read tab named "Transcript"
#   read.sh 1abc123xyz --tab-index 1      # Read second tab
#   read.sh 1abc123xyz --all-tabs         # Read all tabs

source "$(dirname "$0")/../../_auth.sh"

DOC_ID="$1"
shift

if [ -z "$DOC_ID" ]; then
  echo "Usage: read.sh <doc_id> [--list-tabs | --tab <name> | --tab-index <n> | --all-tabs]" >&2
  exit 1
fi

# Parse options
LIST_TABS=false
TAB_NAME=""
TAB_INDEX=""
ALL_TABS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --list-tabs)
      LIST_TABS=true
      shift
      ;;
    --tab)
      TAB_NAME="$2"
      shift 2
      ;;
    --tab-index)
      TAB_INDEX="$2"
      shift 2
      ;;
    --all-tabs)
      ALL_TABS=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Fetch document with tabs content
RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://docs.googleapis.com/v1/documents/$DOC_ID?includeTabsContent=true")

# Check for error
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  echo "$RESPONSE" | jq '.'
  exit 1
fi

# Helper jq function to extract text from tab content
extract_text='[.. | .textRun?.content? // empty] | join("")'

if [ "$LIST_TABS" = true ]; then
  # List all tabs with their properties
  echo "$RESPONSE" | jq '{
    title: .title,
    documentId: .documentId,
    tabs: [.tabs | to_entries[] | {
      index: .key,
      title: .value.tabProperties.title,
      tabId: .value.tabProperties.tabId
    }]
  }'

elif [ -n "$TAB_NAME" ]; then
  # Read specific tab by name
  echo "$RESPONSE" | jq --arg name "$TAB_NAME" '{
    title: .title,
    documentId: .documentId,
    tab: (
      .tabs[] | select(.tabProperties.title == $name) | {
        title: .tabProperties.title,
        tabId: .tabProperties.tabId,
        content: [.documentTab.body.content[]? | .. | .textRun?.content? // empty] | join("")
      }
    )
  } // {error: "Tab not found", requestedTab: $name}'

elif [ -n "$TAB_INDEX" ]; then
  # Read specific tab by index
  echo "$RESPONSE" | jq --argjson idx "$TAB_INDEX" '{
    title: .title,
    documentId: .documentId,
    tab: (
      .tabs[$idx] | {
        title: .tabProperties.title,
        tabId: .tabProperties.tabId,
        content: [.documentTab.body.content[]? | .. | .textRun?.content? // empty] | join("")
      }
    )
  }'

elif [ "$ALL_TABS" = true ]; then
  # Read all tabs
  echo "$RESPONSE" | jq '{
    title: .title,
    documentId: .documentId,
    tabs: [.tabs[] | {
      title: .tabProperties.title,
      tabId: .tabProperties.tabId,
      content: [.documentTab.body.content[]? | .. | .textRun?.content? // empty] | join("")
    }]
  }'

else
  # Default: read first tab only (backwards compatible)
  echo "$RESPONSE" | jq '{
    title: .title,
    documentId: .documentId,
    content: [.tabs[0].documentTab.body.content[]? | .. | .textRun?.content? // empty] | join("")
  }'
fi
