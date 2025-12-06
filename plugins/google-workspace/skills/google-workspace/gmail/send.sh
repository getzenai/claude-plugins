#!/bin/bash
# Send an email
# Usage: send.sh <to> <subject> <body>
# Example: send.sh "john@example.com" "Hello" "This is the message body"

source "$(dirname "$0")/../_auth.sh"

TO="$1"
SUBJECT="$2"
BODY="$3"

if [ -z "$TO" ] || [ -z "$SUBJECT" ] || [ -z "$BODY" ]; then
  echo "Usage: send.sh <to> <subject> <body>" >&2
  exit 1
fi

# Create the email in RFC 2822 format
EMAIL="To: $TO
Subject: $SUBJECT
Content-Type: text/plain; charset=utf-8

$BODY"

# Base64url encode the email
ENCODED_EMAIL=$(echo -n "$EMAIL" | base64 | tr '+/' '-_' | tr -d '=')

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"raw\": \"$ENCODED_EMAIL\"}" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"
