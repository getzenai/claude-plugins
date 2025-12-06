---
name: google-workspace
description: Full access to Google Workspace (Drive, Docs, Sheets, Slides, Calendar, Gmail) using curl and the Google APIs directly - no MCP server or additional dependencies required. Use for searching files, reading/writing documents, managing calendar events, and email operations. First check if user has authenticated, if not guide them through the OAuth flow.
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
scripts/check-auth.sh
```

If `USER_NOT_AUTHENTICATED`, guide the user through the Setup section below.

---

## Quick Commands (Recommended)

Use these scripts for common operations. They handle authentication automatically.

### Authentication
```bash
scripts/check-auth.sh
```

### Google Drive
```bash
scripts/list-files.sh [count]              # List recent files
scripts/list-docs.sh [count]               # List recent Google Docs
scripts/search-drive.sh <query> [count]    # Search files by content
scripts/read-doc.sh <document_id>          # Read a Google Doc as text
scripts/create-doc.sh <title>              # Create a new Google Doc
```

### Google Sheets
```bash
scripts/read-sheet.sh <spreadsheet_id> [range]   # Read spreadsheet values
```
Example: `scripts/read-sheet.sh 1abc123xyz "Sheet1!A1:D10"`

### Google Calendar
```bash
scripts/list-events.sh [count]             # List upcoming events
scripts/create-event.sh <summary> <start> <end> [description]
```
Example: `scripts/create-event.sh "Meeting" "2024-12-10T10:00:00" "2024-12-10T11:00:00"`

### Gmail
```bash
scripts/list-emails.sh [count] [query]     # List recent emails
scripts/read-email.sh <message_id>         # Read an email
```
Example: `scripts/list-emails.sh 5 "from:someone@example.com"`

---

**For advanced operations or APIs not covered by scripts, see the API Reference sections below.**

---

## Setup (One-Time per User, ~3 minutes)

**IMPORTANT**: The user needs to provide their `client_id` and `client_secret` from Google Cloud Console. They can get these by creating OAuth 2.0 credentials (Desktop app type) in their Google Cloud project.

### Step 1: Get OAuth Credentials

Ask the user for their `client_id` and `client_secret`. Only these two values are needed:
- `client_id`: looks like `xxx.apps.googleusercontent.com`
- `client_secret`: looks like `GOCSPX-xxx`

The skill's `oauth-app.json` file should already contain the `client_id`.

### Step 2: Generate and Open Authorization URL

**Note**: When running bash commands with special characters like parentheses in values, wrap the entire command in `bash -c '...'` to avoid shell parsing issues.

```bash
bash -c 'CLIENT_ID="YOUR_CLIENT_ID"; SCOPES="https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/documents https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/presentations https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/gmail.modify"; ENCODED_SCOPES=$(echo $SCOPES | sed "s/ /%20/g"); echo "https://accounts.google.com/o/oauth2/auth?client_id=${CLIENT_ID}&redirect_uri=http://localhost&scope=${ENCODED_SCOPES}&response_type=code&access_type=offline&prompt=consent"'
```

Tell the user to open this URL in their browser.

### Step 3: Authorize and Get Redirect URL

1. User signs in with their Google account
2. User clicks "Allow" to grant access to Google Workspace
3. User will be redirected to `http://localhost/?code=XXXXX...` (the page won't load - that's expected)
4. **Ask the user to copy and paste the ENTIRE redirect URL** (not just the code). This is easier for users than extracting just the code parameter.

Example redirect URL:
```
http://localhost/?code=4/0ATx...XXX&scope=https://www.googleapis.com/auth/drive%20...
```

### Step 4: Exchange Code for Refresh Token

Extract the code from the URL (everything between `code=` and `&scope=`) and exchange it:

```bash
bash -c 'CODE="EXTRACTED_CODE"; CLIENT_ID="YOUR_CLIENT_ID"; CLIENT_SECRET="YOUR_CLIENT_SECRET"; curl -s -X POST https://oauth2.googleapis.com/token -d "code=$CODE" -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET" -d "redirect_uri=http://localhost" -d "grant_type=authorization_code"'
```

This returns JSON with `access_token` and `refresh_token`. Save the `refresh_token`.

### Step 5: Store Credentials

```bash
mkdir -p ~/.config/gdrive-skill && cat > ~/.config/gdrive-skill/credentials.json << 'EOF'
{
  "client_secret": "YOUR_CLIENT_SECRET",
  "refresh_token": "YOUR_REFRESH_TOKEN"
}
EOF
chmod 600 ~/.config/gdrive-skill/credentials.json && echo "Credentials saved!"
```

Setup complete!

---

## Authentication

Before making API calls, get a fresh access token. Use `bash -c` to avoid shell parsing issues:

```bash
bash -c 'CLIENT_ID=$(jq -r ".client_id" /PATH/TO/oauth-app.json); USER_CREDS=$(cat ~/.config/gdrive-skill/credentials.json); CLIENT_SECRET=$(echo $USER_CREDS | jq -r ".client_secret"); REFRESH_TOKEN=$(echo $USER_CREDS | jq -r ".refresh_token"); ACCESS_TOKEN=$(curl -s -X POST https://oauth2.googleapis.com/token -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET" -d "refresh_token=$REFRESH_TOKEN" -d "grant_type=refresh_token" | jq -r ".access_token"); echo "ACCESS_TOKEN=$ACCESS_TOKEN"'
```

Replace `/PATH/TO/oauth-app.json` with the actual path to the skill's oauth-app.json file (shown in "Base directory for this skill" when the skill loads).

For subsequent API calls, store the access token and use it:

```bash
bash -c 'ACCESS_TOKEN="YOUR_ACCESS_TOKEN"; curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "https://www.googleapis.com/drive/v3/files?pageSize=5"'
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
