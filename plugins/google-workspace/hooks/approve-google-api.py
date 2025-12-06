#!/usr/bin/env python3
"""
PermissionRequest hook for google-workspace plugin.
Auto-approves safe bash commands for Google API operations.
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

# Safe URL patterns for Google APIs
SAFE_URL_PATTERNS = [
    r"https://www\.googleapis\.com/",
    r"https://oauth2\.googleapis\.com/",
    r"https://docs\.googleapis\.com/",
    r"https://sheets\.googleapis\.com/",
    r"https://gmail\.googleapis\.com/",
    r"https://accounts\.google\.com/o/oauth2/",
]

# Safe command patterns (non-URL commands)
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
    # Skill scripts (list-docs.sh, read-doc.sh, etc.)
    r".*/plugins/google-workspace/skills/google-workspace/scripts/.*\.sh",
]


def is_safe_curl_command(command: str) -> bool:
    """Check if a curl command only targets safe Google API URLs."""
    # Must be a curl command
    if not re.search(r'\bcurl\b', command):
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
    # Check curl commands separately
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

    tool_name = input_data.get("tool_name")  # Field is "tool_name", not "tool"
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
            is_safe_curl_command(subcmd.strip()) or
            # Allow variable assignments and echo
            re.match(r'^[A-Z_]+=', subcmd.strip()) or
            re.match(r'^echo ', subcmd.strip())
            for subcmd in subcommands if subcmd.strip()
        )
        if all_safe:
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PermissionRequest",
                    "decision": {
                        "behavior": "allow",
                        "message": "Auto-approved: Google Workspace API command"
                    }
                }
            }))
            sys.exit(0)

    # Check direct commands
    if is_safe_command(command):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PermissionRequest",
                "decision": {
                    "behavior": "allow",
                    "message": "Auto-approved: Google Workspace API command"
                }
            }
        }))
        sys.exit(0)

    # Not a recognized safe command, let normal permission flow proceed
    sys.exit(0)


if __name__ == "__main__":
    main()
