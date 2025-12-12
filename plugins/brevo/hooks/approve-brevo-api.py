#!/usr/bin/env python3
"""
Auto-approval hook for Brevo API operations.

Safe operations (auto-approved):
- All GET requests (list, get)
- check-auth.sh

Operations requiring approval:
- POST requests (create contacts, create campaigns)
"""

import json
import os
import re
import sys
from datetime import datetime

# Debug log path
DEBUG_LOG = os.path.expanduser("~/.config/brevo/hook-debug.log")


def log_debug(message: str):
    """Write debug message to log file."""
    os.makedirs(os.path.dirname(DEBUG_LOG), exist_ok=True)
    with open(DEBUG_LOG, "a") as f:
        f.write(f"{datetime.now().isoformat()} - {message}\n")


def is_safe_operation(command: str) -> bool:
    """
    Determine if a command is safe to auto-approve.

    Safe operations:
    - check-auth.sh
    - */list.sh (read operations)
    - */get.sh (read operations)

    Unsafe operations:
    - */create.sh (writes data)
    """
    # Patterns for safe operations (read-only)
    safe_patterns = [
        r"check-auth\.sh",
        r"/list\.sh",
        r"/get\.sh",
    ]

    # Patterns for unsafe operations (writes)
    unsafe_patterns = [
        r"/create\.sh",
    ]

    # Check if it's explicitly unsafe first
    for pattern in unsafe_patterns:
        if re.search(pattern, command):
            log_debug(f"UNSAFE (matches {pattern}): {command}")
            return False

    # Check if it matches a safe pattern
    for pattern in safe_patterns:
        if re.search(pattern, command):
            log_debug(f"SAFE (matches {pattern}): {command}")
            return True

    # If no pattern matches, check for raw curl commands
    # Allow GET requests, deny POST/PATCH/DELETE
    if "curl" in command:
        if "-X POST" in command or "-X PATCH" in command or "-X DELETE" in command:
            log_debug(f"UNSAFE (curl with write method): {command}")
            return False
        # GET requests (no -X or -X GET)
        if "-X" not in command or "-X GET" in command:
            log_debug(f"SAFE (curl GET): {command}")
            return True

    # Default: not safe, require approval
    log_debug(f"UNKNOWN (defaulting to unsafe): {command}")
    return False


def main():
    log_debug("=== Hook triggered ===")

    try:
        # Read input from stdin
        input_data = sys.stdin.read()
        log_debug(f"Received input: {input_data[:500]}...")

        request = json.loads(input_data)

        tool_name = request.get("tool_name", "")
        tool_input = request.get("tool_input", {})
        command = tool_input.get("command", "")

        log_debug(f"Tool: {tool_name}, Command: {command}")

        # Only process Bash commands
        if tool_name != "Bash":
            # Let other tools go through normal approval flow
            sys.exit(0)

        # Check if this is a Brevo related command
        if "brevo" not in command.lower():
            # Not a Brevo command, let it go through normal flow
            sys.exit(0)

        if is_safe_operation(command):
            log_debug(f"AUTO-APPROVED: {command}")
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PermissionRequest",
                    "decision": {
                        "behavior": "allow",
                        "message": "Auto-approved: Brevo read operation"
                    }
                }
            }))
            sys.exit(0)
        else:
            log_debug(f"REQUIRES APPROVAL: {command}")
            # Let unsafe operations go through normal approval flow
            sys.exit(0)

    except Exception as e:
        log_debug(f"ERROR: {str(e)}")
        # On error, let it go through normal approval
        sys.exit(0)


if __name__ == "__main__":
    main()
