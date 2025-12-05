---
name: google-workspace
description: Full access to Google Workspace - Drive, Docs, Sheets, Slides, Calendar, and Gmail. Use for searching files, reading/writing documents, managing calendar events, and email operations. First check if user has authenticated, if not guide them through the OAuth flow.
---

# Google Workspace Integration

This skill provides full access to Google Workspace APIs via curl commands.

## Capabilities

- **Drive**: Search, read, create, and organize files
- **Docs**: Read and write documents
- **Sheets**: Read and write spreadsheets
- **Slides**: Read and write presentations
- **Calendar**: Read and write calendar events
- **Gmail**: Read, send, and manage emails

## Pre-flight Check

Check if user has set up their credentials:

```bash
if [ -f ~/.config/gdrive-skill/credentials.json ]; then
  echo "USER_AUTHENTICATED"
else
  echo "USER_NOT_AUTHENTICATED"
fi
```

If `USER_NOT_AUTHENTICATED`, guide the user through the Setup section below.

---

## Setup (One-Time per User, ~3 minutes)

### Step 1: Get Client Secret from Admin

Ask your team admin for the `client_secret`. They should share it via a secure channel (1Password, Slack DM, etc.).

### Step 2: Open Authorization URL

```bash
CLIENT_ID=$(cat .claude/skills/gdrive/oauth-app.json | jq -r '.client_id')
SCOPES="https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/documents https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/presentations https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/gmail.modify"
ENCODED_SCOPES=$(echo $SCOPES | sed 's/ /%20/g')
echo "Open this URL in your browser:"
echo "https://accounts.google.com/o/oauth2/auth?client_id=${CLIENT_ID}&redirect_uri=http://localhost&scope=${ENCODED_SCOPES}&response_type=code&access_type=offline&prompt=consent"
```

### Step 3: Authorize and Copy Code

1. Sign in with your Google account
2. Click "Allow" to grant access to Google Workspace
3. You'll be redirected to `http://localhost/?code=XXXXX...`
4. Copy the `code` value from the URL (everything after `code=` and before any `&`)

### Step 4: Exchange Code for Refresh Token

Run this command (replace YOUR_AUTH_CODE and YOUR_CLIENT_SECRET):

```bash
CLIENT_ID=$(cat .claude/skills/gdrive/oauth-app.json | jq -r '.client_id')

curl -s -X POST https://oauth2.googleapis.com/token \
  -d "code=YOUR_AUTH_CODE" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "redirect_uri=http://localhost" \
  -d "grant_type=authorization_code"
```

This returns JSON. Copy the `refresh_token` value.

### Step 5: Store Credentials

```bash
mkdir -p ~/.config/gdrive-skill
cat > ~/.config/gdrive-skill/credentials.json << 'EOF'
{
  "client_secret": "YOUR_CLIENT_SECRET",
  "refresh_token": "YOUR_REFRESH_TOKEN"
}
EOF
chmod 600 ~/.config/gdrive-skill/credentials.json
```

Setup complete!

---

## Authentication

Before making API calls, get a fresh access token:

```bash
CLIENT_ID=$(cat .claude/skills/gdrive/oauth-app.json | jq -r '.client_id')
USER_CREDS=$(cat ~/.config/gdrive-skill/credentials.json)
CLIENT_SECRET=$(echo $USER_CREDS | jq -r '.client_secret')
REFRESH_TOKEN=$(echo $USER_CREDS | jq -r '.refresh_token')

ACCESS_TOKEN=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "grant_type=refresh_token" | jq -r '.access_token')

if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: Failed to get access token. Re-run setup."
  exit 1
fi
```

---

## Advanced Search Reference

Google Drive API supports powerful query operators beyond simple keyword search.

### Query Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=`, `!=` | Exact match | `name = 'Report.pdf'` |
| `<`, `<=`, `>`, `>=` | Date/time comparison | `modifiedTime > '2024-01-01'` |
| `contains` | Substring match | `name contains 'meeting'` |
| `in` | Collection membership | `'user@example.com' in owners` |
| `and`, `or`, `not` | Logical operators | `name contains 'a' and name contains 'b'` |

### Searchable Fields

| Field | Description |
|-------|-------------|
| `name` | File name |
| `fullText` | Searches name, description, and content |
| `mimeType` | File type (e.g., `application/vnd.google-apps.document`) |
| `modifiedTime` | Last modification (RFC 3339: `2024-12-01T00:00:00Z`) |
| `createdTime` | Creation date |
| `viewedByMeTime` | Last viewed by user |
| `trashed` | In trash (true/false) |
| `starred` | Starred (true/false) |
| `parents` | Parent folder ID |
| `owners` | File owner email |
| `writers` | Users with write access |
| `readers` | Users with read access |
| `sharedWithMe` | In "Shared with me" |

---

## Google Drive API

### Search Files by Content

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=fullText%20contains%20'SEARCH_TERM'&fields=files(id,name,mimeType,modifiedTime,webViewLink)"
```

### Search by Name and Date Range

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=name%20contains%20'meeting'%20and%20modifiedTime%20%3E%20'2024-01-01T00:00:00Z'&fields=files(id,name,mimeType,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc"
```

### Files Modified in Last 7 Days

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=modifiedTime%20%3E%20'$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)'&fields=files(id,name,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc"
```

### Google Docs Only

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=mimeType%3D'application/vnd.google-apps.document'&fields=files(id,name,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc"
```

### Files Shared With Me

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=sharedWithMe%3Dtrue&fields=files(id,name,modifiedTime,webViewLink)&orderBy=modifiedTime%20desc"
```

### List Recent Files

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?orderBy=modifiedTime%20desc&pageSize=20&fields=files(id,name,mimeType,modifiedTime,webViewLink)"
```

### Create a Folder

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "FOLDER_NAME", "mimeType": "application/vnd.google-apps.folder"}' \
  "https://www.googleapis.com/drive/v3/files"
```

### Upload a File

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata={name: 'filename.txt'};type=application/json;charset=UTF-8" \
  -F "file=@/path/to/file.txt" \
  "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
```

---

## Google Docs API

### Read Document as Plain Text

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files/DOCUMENT_ID/export?mimeType=text/plain"
```

### Get Document Structure

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://docs.googleapis.com/v1/documents/DOCUMENT_ID"
```

### Create a New Document

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "New Document Title"}' \
  "https://docs.googleapis.com/v1/documents"
```

### Append Text to Document

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "requests": [{
      "insertText": {
        "location": {"index": 1},
        "text": "Text to insert"
      }
    }]
  }' \
  "https://docs.googleapis.com/v1/documents/DOCUMENT_ID:batchUpdate"
```

---

## Google Sheets API

### Read Spreadsheet Values

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:Z100"
```

### Get Spreadsheet Metadata

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID"
```

### Write Values to Sheet

```bash
curl -s -X PUT -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "values": [
      ["Row1Col1", "Row1Col2"],
      ["Row2Col1", "Row2Col2"]
    ]
  }' \
  "https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:B2?valueInputOption=USER_ENTERED"
```

### Append Row to Sheet

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "values": [["Value1", "Value2", "Value3"]]
  }' \
  "https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A:C:append?valueInputOption=USER_ENTERED"
```

---

## Google Calendar API

### List Upcoming Events

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/primary/events?maxResults=10&orderBy=startTime&singleEvents=true&timeMin=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### Get Event Details

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/calendar/v3/calendars/primary/events/EVENT_ID"
```

### Create Calendar Event

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "summary": "Meeting Title",
    "description": "Meeting description",
    "start": {"dateTime": "2024-12-10T10:00:00", "timeZone": "America/New_York"},
    "end": {"dateTime": "2024-12-10T11:00:00", "timeZone": "America/New_York"},
    "attendees": [{"email": "attendee@example.com"}]
  }' \
  "https://www.googleapis.com/calendar/v3/calendars/primary/events?sendUpdates=all"
```

### Check Free/Busy

```bash
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "timeMin": "2024-12-10T00:00:00Z",
    "timeMax": "2024-12-10T23:59:59Z",
    "items": [{"id": "primary"}]
  }' \
  "https://www.googleapis.com/calendar/v3/freeBusy"
```

---

## Gmail API

### List Recent Emails

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=10"
```

### Search Emails

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages?q=from:someone@example.com%20subject:important"
```

### Get Email Content

```bash
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages/MESSAGE_ID?format=full"
```

### Send Email

```bash
# Create email content (base64 encoded)
EMAIL_CONTENT=$(echo -e "To: recipient@example.com\nSubject: Email Subject\nContent-Type: text/plain; charset=utf-8\n\nEmail body text here" | base64 -w 0)

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"raw\": \"$EMAIL_CONTENT\"}" \
  "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"
```

### Create Draft

```bash
EMAIL_CONTENT=$(echo -e "To: recipient@example.com\nSubject: Draft Subject\n\nDraft body" | base64 -w 0)

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"message\": {\"raw\": \"$EMAIL_CONTENT\"}}" \
  "https://gmail.googleapis.com/gmail/v1/users/me/drafts"
```

---

## Usage Patterns

1. **Find meeting transcript**: Search Drive for keywords from meetings
2. **Extract action items**: Read transcript, analyze content
3. **Update project tracker**: Write to Sheets spreadsheet
4. **Schedule follow-up**: Create Calendar event
5. **Send summary email**: Compose and send via Gmail
6. **Create meeting notes**: Generate new Google Doc

## Troubleshooting

- **"Failed to get access token"**: Refresh token may have expired. Re-run setup.
- **Empty search results**: Try broader search terms
- **403 Forbidden**: User may not have access to the resource
- **400 Bad Request**: Check JSON formatting in request body
