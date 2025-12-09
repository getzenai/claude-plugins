---
name: google-workspace
description: Full access to Google Workspace (Drive, Docs, Sheets, Slides, Calendar, Gmail) using curl and the Google APIs directly - no MCP server or additional dependencies required. Use for searching files, reading/writing documents, managing calendar events, and email operations. First check if user has authenticated, if not guide them through the OAuth flow.
---

# Google Workspace Integration

This skill provides full access to Google Workspace APIs via helper scripts.

## Capabilities

- **Drive**: Search, list, upload, download, and delete files
- **Docs**: List, search, read, create, and write documents
- **Sheets**: List, search, read, write, append, and create spreadsheets
- **Slides**: List, search, read, and create presentations
- **Calendar**: List, search, get, create, update, and delete events
- **Gmail**: List, search, read, send, and draft emails

## Pre-flight Check

Check if user has set up their credentials:

```bash
check-auth.sh
```

If `USER_NOT_AUTHENTICATED`, guide the user through the Setup section below.

---

## Scripts Reference

All scripts handle authentication automatically. Prepend the base directory path to all script paths.

### Drive - General

```bash
drive/search.sh <query> [count]        # Search all files by content
```

### Drive - Files

```bash
drive/files/list.sh [count]            # List recent files
drive/files/upload.sh <local_path> [folder_id]    # Upload file
drive/files/download.sh <file_id> <output_path>   # Download file
drive/files/delete.sh <file_id>        # Move file to trash
```

### Drive - Docs

```bash
drive/docs/list.sh [count]             # List recent Google Docs
drive/docs/search.sh <query>           # Search docs by name
drive/docs/read.sh <doc_id> [options]  # Read document content (supports tabs)
drive/docs/create.sh <title> [folder_id]    # Create new doc
drive/docs/write.sh <doc_id> <text> [index] # Write/append text
```

**Document Tabs**: Google Docs can have multiple tabs. The `read.sh` script supports:

```bash
drive/docs/read.sh <doc_id>                    # Read first tab (default)
drive/docs/read.sh <doc_id> --list-tabs        # List all tabs in document
drive/docs/read.sh <doc_id> --tab "Transcript" # Read tab by name
drive/docs/read.sh <doc_id> --tab-index 1      # Read tab by index (0-based)
drive/docs/read.sh <doc_id> --all-tabs         # Read all tabs
```

### Drive - Sheets

```bash
drive/sheets/list.sh [count]           # List recent spreadsheets
drive/sheets/search.sh <query>         # Search sheets by name
drive/sheets/read.sh <id> [range]      # Read sheet values
drive/sheets/write.sh <id> <range> <values_json>  # Write values
drive/sheets/append.sh <id> <sheet_name> <values_json> # Append rows
drive/sheets/create.sh <title> [folder_id]  # Create new sheet
```

Example: `drive/sheets/write.sh 1abc "Sheet1!A1:B2" '[["Name","Age"],["John",30]]'`

### Drive - Slides

```bash
drive/slides/list.sh [count]           # List recent presentations
drive/slides/search.sh <query>         # Search slides by name
drive/slides/read.sh <presentation_id> # Read presentation
drive/slides/create.sh <title> [folder_id]  # Create new presentation
```

### Calendar

```bash
calendar/calendars.sh                  # List all calendars
calendar/list.sh [count] [calendar_id] # List upcoming events
calendar/search.sh <query> [count] [calendar_id]  # Search events
calendar/get.sh <event_id> [calendar_id]   # Get event details
calendar/create.sh <summary> <start> <end> [description] [calendar_id]
calendar/update.sh <event_id> <json_updates> [calendar_id]
calendar/delete.sh <event_id> [calendar_id]
```

Example: `calendar/create.sh "Meeting" "2024-12-10T10:00:00" "2024-12-10T11:00:00"`

### Gmail

```bash
gmail/labels.sh                        # List all labels
gmail/list.sh [count] [label]          # List recent emails
gmail/search.sh <query> [count]        # Search emails
gmail/read.sh <message_id> [format]    # Read email content
gmail/send.sh <to> <subject> <body>    # Send email
gmail/draft.sh <to> <subject> <body>   # Create draft
```

Example: `gmail/search.sh "from:john@example.com" 5`

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

## Advanced Search Reference

Google Drive API supports powerful query operators beyond simple keyword search.

### Query Operators

| Operator             | Description           | Example                                   |
| -------------------- | --------------------- | ----------------------------------------- |
| `=`, `!=`            | Exact match           | `name = 'Report.pdf'`                     |
| `<`, `<=`, `>`, `>=` | Date/time comparison  | `modifiedTime > '2024-01-01'`             |
| `contains`           | Substring match       | `name contains 'meeting'`                 |
| `in`                 | Collection membership | `'user@example.com' in owners`            |
| `and`, `or`, `not`   | Logical operators     | `name contains 'a' and name contains 'b'` |

### Searchable Fields

| Field            | Description                                              |
| ---------------- | -------------------------------------------------------- |
| `name`           | File name                                                |
| `fullText`       | Searches name, description, and content                  |
| `mimeType`       | File type (e.g., `application/vnd.google-apps.document`) |
| `modifiedTime`   | Last modification (RFC 3339: `2024-12-01T00:00:00Z`)     |
| `createdTime`    | Creation date                                            |
| `viewedByMeTime` | Last viewed by user                                      |
| `trashed`        | In trash (true/false)                                    |
| `starred`        | Starred (true/false)                                     |
| `parents`        | Parent folder ID                                         |
| `owners`         | File owner email                                         |
| `writers`        | Users with write access                                  |
| `readers`        | Users with read access                                   |
| `sharedWithMe`   | In "Shared with me"                                      |

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
