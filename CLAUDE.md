# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugins repository by Zen AI. It provides plugins that extend Claude Code's capabilities, currently featuring the **google-workspace** plugin for Google Workspace API integration (Drive, Docs, Sheets, Slides, Calendar, Gmail).

## Architecture

```
claude-plugins/
├── plugins/
│   └── google-workspace/
│       ├── .claude-plugin/
│       │   └── plugin.json         # Plugin metadata (name, version, author)
│       ├── hooks/
│       │   ├── hooks.json          # Hook configuration
│       │   └── approve-google-api.py  # Auto-approval hook for safe operations
│       └── skills/
│           └── google-workspace/
│               ├── SKILL.md        # Skill documentation and setup instructions
│               ├── oauth-app.json  # OAuth client_id (gitignored)
│               ├── _auth.sh        # Shared auth component (sourced by other scripts)
│               ├── check-auth.sh   # Verify user authentication status
│               ├── drive/          # Drive, Docs, Sheets, Slides scripts
│               ├── calendar/       # Calendar CRUD operations
│               └── gmail/          # Email operations
```

## Key Components

### Authentication System

- `_auth.sh`: Shared component that all API scripts source to get `ACCESS_TOKEN`
- User credentials stored in `~/.config/gdrive-skill/credentials.json` (never committed)
- OAuth client_id in `oauth-app.json`, client_secret stored with user credentials

### Permission Hook (`approve-google-api.py`)

Auto-approves safe read-only operations without user prompts:

- Safe: list, search, read, download, create empty docs, drafts
- Needs approval: send emails, write/modify content, delete files, calendar modifications

### Script Naming Convention

Scripts follow a consistent pattern: `<service>/<action>.sh`

- All scripts source `_auth.sh` for authentication
- Arguments documented in SKILL.md
- Return JSON from Google APIs

## Plugin Distribution

Plugins can be installed via:

1. Plugin marketplace: `/plugin marketplace add getzenai/claude-plugins`
2. Manual installation: Copy skill folder to `.claude/skills/`

## Credentials

| File               | Location                  | Committed          |
| ------------------ | ------------------------- | ------------------ |
| `oauth-app.json`   | Plugin skill folder       | No (gitignored)    |
| `credentials.json` | `~/.config/gdrive-skill/` | No (user-specific) |

## Google API Documentation

- [Calendar API v3](https://developers.google.com/workspace/calendar/api/v3/reference)
- [Docs API](https://developers.google.com/workspace/docs/api/how-tos/overview)
- [Sheets API](https://developers.google.com/workspace/sheets/api/guides/concepts)
- [Gmail API](https://developers.google.com/workspace/gmail/api/guides)
- [Slides API](https://developers.google.com/workspace/slides/api/reference/rest)
- [Drive API Search](https://developers.google.com/drive/api/guides/ref-search-terms)
