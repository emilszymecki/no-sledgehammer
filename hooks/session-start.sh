#!/usr/bin/env bash
# SessionStart: injects rules/rules.md into the context (additionalContext).
# Fail-open: without jq or the file it prints nothing and exits 0.
command -v jq >/dev/null 2>&1 || exit 0
file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)/rules/rules.md"
[ -r "$file" ] || exit 0
jq -Rs '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}}' <"$file" 2>/dev/null || exit 0
exit 0
