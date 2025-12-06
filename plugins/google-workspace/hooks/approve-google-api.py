#!/usr/bin/env python3
"""
PermissionRequest hook for google-workspace plugin.
Auto-approves safe bash commands for Google API operations.

Safe (auto-approved):
- All read/list/search operations
- Creating empty docs/sheets/slides
- Downloading files
- Creating drafts (not sent)

Needs approval:
- Sending emails
- Creating/updating/deleting calendar events
- Writing/modifying file content
- Uploading/deleting files
"""

import json
import sys
import re
import os

# Debug logging to a file
DEBUG_LOG = os.path.expanduser("~/.config/gdrive-skill/hook-debug.log")

def log_debug(msg):
    with open(DEBUG_LOG, "a") as f:
        f.write(f"{msg}\n")

# Safe URL patterns for Google APIs (read operations)
SAFE_URL_PATTERNS = [
    r"https://www\.googleapis\.com/",
    r"https://oauth2\.googleapis\.com/",
    r"https://docs\.googleapis\.com/",
    r"https://sheets\.googleapis\.com/",
    r"https://gmail\.googleapis\.com/",
    r"https://accounts\.google\.com/o/oauth2/",
]

# Scripts that are always safe to auto-approve (read-only operations)
SAFE_SCRIPTS = [
    # Auth
    r"check-auth\.sh",
    # Drive - read operations
    r"drive/search\.sh",
    r"drive/files/list\.sh",
    r"drive/files/download\.sh",
    # Docs - read operations + create (empty doc)
    r"drive/docs/list\.sh",
    r"drive/docs/search\.sh",
    r"drive/docs/read\.sh",
    r"drive/docs/create\.sh",
    # Sheets - read operations + create (empty sheet)
    r"drive/sheets/list\.sh",
    r"drive/sheets/search\.sh",
    r"drive/sheets/read\.sh",
    r"drive/sheets/create\.sh",
    # Slides - read operations + create (empty presentation)
    r"drive/slides/list\.sh",
    r"drive/slides/search\.sh",
    r"drive/slides/read\.sh",
    r"drive/slides/create\.sh",
    # Calendar - read operations only
    r"calendar/calendars\.sh",
    r"calendar/list\.sh",
    r"calendar/search\.sh",
    r"calendar/get\.sh",
    # Gmail - read operations + draft (not sent)
    r"gmail/labels\.sh",
    r"gmail/list\.sh",
    r"gmail/search\.sh",
    r"gmail/read\.sh",
    r"gmail/draft\.sh",
]

# Scripts that need user approval (write/modify/delete operations)
# These are NOT auto-approved:
# - drive/files/upload.sh
# - drive/files/delete.sh
# - drive/docs/write.sh
# - drive/sheets/write.sh
# - drive/sheets/append.sh
# - calendar/create.sh
# - calendar/update.sh
# - calendar/delete.sh
# - gmail/send.sh

# Safe command patterns (non-script commands)
SAFE_COMMAND_PATTERNS = [
    # Credentials directory setup
    r"^mkdir -p ~/\.config/gdrive-skill",
    r"^mkdir -p \$HOME/\.config/gdrive-skill",
    # Check if credentials exist
    r"^if \[ -f ~/\.config/gdrive-skill/credentials\.json \]",
    r'^\[ -f ~/\.config/gdrive-skill/credentials\.json \]',
    # Read credentials file
    r"^cat ~/\.config/gdrive-skill/credentials\.json",
    r"^cat \$HOME/\.config/gdrive-skill/credentials\.json",
    # chmod for credentials
    r"^chmod 600 ~/\.config/gdrive-skill/credentials\.json",
    # jq commands for JSON parsing
    r'^jq ',
    r'^echo .* \| jq',
]


def is_safe_script(command: str) -> bool:
    """Check if command is calling a safe skill script."""
    for pattern in SAFE_SCRIPTS:
        if re.search(pattern, command):
            return True
    return False


def is_safe_curl_command(command: str) -> bool:
    """Check if a curl command only targets safe Google API URLs and is read-only."""
    # Must be a curl command
    if not re.search(r'\bcurl\b', command):
        return False

    # Reject if it's a write operation (POST, PUT, PATCH, DELETE)
    if re.search(r'-X\s*(POST|PUT|PATCH|DELETE)', command):
        return False

    # Also reject -d (data) which indicates a write
    if re.search(r'\s-d\s', command):
        return False

    # Extract all URLs from the command
    url_pattern = r'https?://[^\s"\'>]+'
    urls = re.findall(url_pattern, command)

    if not urls:
        return False

    # All URLs must match safe patterns
    for url in urls:
        is_safe = any(re.search(pattern, url) for pattern in SAFE_URL_PATTERNS)
        if not is_safe:
            return False

    return True


def is_safe_command(command: str) -> bool:
    """Check if a command matches safe patterns."""
    # Check if it's a safe script call
    if is_safe_script(command):
        return True

    # Check curl commands - only allow GET requests
    if 'curl' in command:
        return is_safe_curl_command(command)

    # Check other safe patterns
    for pattern in SAFE_COMMAND_PATTERNS:
        if re.search(pattern, command):
            return True

    return False


def main():
    log_debug("=== Hook triggered ===")

    try:
        stdin_data = sys.stdin.read()
        log_debug(f"Received stdin: {stdin_data[:500]}")
        input_data = json.loads(stdin_data)
    except json.JSONDecodeError as e:
        log_debug(f"JSON decode error: {e}")
        sys.exit(0)  # Let normal permission flow proceed

    log_debug(f"Parsed input keys: {list(input_data.keys())}")

    tool_name = input_data.get("tool_name")
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    log_debug(f"tool_name: {tool_name}")
    log_debug(f"command: {command[:200] if command else 'None'}")

    # Only handle Bash commands
    if tool_name != "Bash":
        sys.exit(0)

    # Check if this is a bash -c wrapper (common pattern)
    bash_c_match = re.match(r"^bash -c '(.+)'$", command, re.DOTALL)
    if bash_c_match:
        inner_command = bash_c_match.group(1)
        # For bash -c, check if all parts are safe
        # Split on ; to check each subcommand
        subcommands = inner_command.split(';')
        all_safe = all(
            is_safe_command(subcmd.strip()) or
            # Allow variable assignments and echo
            re.match(r'^[A-Z_]+=', subcmd.strip()) or
            re.match(r'^echo ', subcmd.strip())
            for subcmd in subcommands if subcmd.strip()
        )
        if all_safe:
            log_debug("Auto-approved: bash -c command with safe subcommands")
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PermissionRequest",
                    "decision": {
                        "behavior": "allow",
                        "message": "Auto-approved: Google Workspace read operation"
                    }
                }
            }))
            sys.exit(0)

    # Check direct commands
    if is_safe_command(command):
        log_debug(f"Auto-approved: {command[:100]}")
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PermissionRequest",
                "decision": {
                    "behavior": "allow",
                    "message": "Auto-approved: Google Workspace read operation"
                }
            }
        }))
        sys.exit(0)

    log_debug(f"Not auto-approved, requires user confirmation: {command[:100]}")
    # Not a recognized safe command, let normal permission flow proceed
    sys.exit(0)


if __name__ == "__main__":
    main()
