# Claude Code Plugins by Zen AI

A collection of [Claude Code](https://claude.ai/code) plugins. Currently includes **google-workspace** which provides full access to Google Workspace APIs (Drive, Docs, Sheets, Slides, Calendar, Gmail) using curl and the Google APIs directly - no MCP server or additional dependencies required.

## Installation

### Option 1: Install from Plugin Marketplace (Recommended)

```bash
# Add this repository as a marketplace
/plugin marketplace add getzenai/claude-plugins

# Install the skill
/plugin install google-workspace@getzenai-claude-plugins
```

### Option 2: Manual Installation

```bash
# Clone this repo
git clone https://github.com/getzenai/claude-plugins.git

# Copy to your project
mkdir -p your-project/.claude/skills/gdrive
cp claude-plugins/skills/google-workspace/* your-project/.claude/skills/gdrive/

# Create oauth-app.json from example
mv your-project/.claude/skills/gdrive/oauth-app.json.example your-project/.claude/skills/gdrive/oauth-app.json
# Edit oauth-app.json and add your client_id
```

## Features

- **Google Drive**: Search (with powerful query operators), read, create, and organize files
- **Google Docs**: Read and write documents
- **Google Sheets**: Read and write spreadsheets
- **Google Slides**: Read and write presentations
- **Google Calendar**: Read and write calendar events
- **Gmail**: Read, send, and manage emails

### Advanced Search Capabilities

The skill includes comprehensive Google Drive search with:

| Operator | Example |
|----------|---------|
| Content search | `fullText contains 'keyword'` |
| Name matching | `name contains 'meeting'` |
| Date filtering | `modifiedTime > '2024-01-01'` |
| File type | `mimeType = 'application/vnd.google-apps.document'` |
| Ownership | `'user@example.com' in owners` |
| Shared files | `sharedWithMe = true` |
| Combine with | `and`, `or`, `not` |

## Setup

### Part 1: Google Cloud Project (One-time, ~10 minutes)

One person (admin) creates the shared OAuth app:

#### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click "Select a project" → "New Project"
3. Name it (e.g., "Claude Workspace Access")
4. Click "Create"

#### Step 2: Enable APIs

Go to **APIs & Services** → **Library** and enable:
- Google Drive API
- Google Docs API
- Google Sheets API
- Google Slides API
- Google Calendar API
- Gmail API

#### Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose user type:
   - **Internal** (recommended for Google Workspace organizations)
   - **External** (for personal accounts)
3. Fill in app information:
   - App name: "Claude Workspace Access"
   - User support email: your email
   - Developer contact: your email
4. Add scopes:
   - `https://www.googleapis.com/auth/drive`
   - `https://www.googleapis.com/auth/documents`
   - `https://www.googleapis.com/auth/spreadsheets`
   - `https://www.googleapis.com/auth/presentations`
   - `https://www.googleapis.com/auth/calendar`
   - `https://www.googleapis.com/auth/gmail.modify`

#### Step 4: Create OAuth Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **Desktop app**
4. Name: "Claude Code"
5. Click **Create**
6. **Save the Client ID and Client Secret**

#### Step 5: Store Credentials

Create `oauth-app.json` in your skill folder:

```json
{
  "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com"
}
```

**Important**: The `client_secret` is sensitive and should NOT be committed to your repository.

### Part 2: User Authentication (Each user, ~3 minutes)

Each user needs to complete this once:

1. **Get client_secret** from admin (a secure channel)
2. **Generate auth URL** and open in browser
3. **Authorize** and copy the code from redirect URL
4. **Exchange code** for refresh token
5. **Store credentials** in `~/.config/gdrive-skill/credentials.json`

The skill will guide you through these steps when you first use it.

## Usage

Once set up, ask Claude Code things like:

- "Search my Google Drive for files about the product launch"
- "Find all documents modified in the last 7 days"
- "Read the document with ID xyz123"
- "List my upcoming calendar events"
- "Create a new Google Doc called 'Meeting Notes'"
- "Send an email to team@example.com"

## Security

| Credential | Storage | Committed? |
|------------|---------|------------|
| `client_id` | `oauth-app.json` | Yes (public anyway) |
| `client_secret` | Secure storage | No |
| `refresh_token` | `~/.config/gdrive-skill/` | No (personal) |

### Revoking Access

1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Find "Third-party apps with account access"
3. Remove "Claude Workspace Access"

## File Structure

```
claude-plugins/
├── README.md
├── LICENSE
├── .gitignore
└── skills/
    └── google-workspace/
        ├── SKILL.md                  # Skill instructions
        └── oauth-app.json.example    # Template for client_id

~/.config/gdrive-skill/
└── credentials.json                  # User's secrets (never committed)
```

## Customization

Edit the skill to add:
- Project-specific search patterns
- Common document IDs
- Language-specific search terms (e.g., German keywords)
- Team-specific workflows

## Troubleshooting

| Error | Solution |
|-------|----------|
| "Failed to get access token" | Refresh token expired. Re-run user setup. |
| Empty search results | Try broader terms, check "Shared with me" |
| 403 Forbidden | User doesn't have access to resource |
| 400 Bad Request | Check JSON formatting |
| "invalid_grant" | Auth code expired (~10 min). Generate new one. |

## References

- [Google Drive API Search](https://developers.google.com/drive/api/guides/ref-search-terms)
- [Claude Code Plugins](https://www.claude.com/blog/claude-code-plugins)
- [Anthropic Skills Marketplace](https://github.com/anthropics/skills)

## License

MIT
