#!/usr/bin/env bash
# PreToolUse on Agent: a subagent without a `model` field inherits the
# session model (the "sledgehammer" case: several reviewers on the strongest
# model burn ~1.5M tokens). The rules (rules/rules.md) say to pick a model on
# every call; this hook rejects a call that has none.
# Passes: an explicit `model`, `fork` (inherits by design), and an agent type
# whose definition (.claude/agents/*.md) pins its own model.
# The hook only makes sure a choice is MADE. Which model is up to the orchestrator.
# Fail-open: without jq or on unreadable input we do not block work.
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
jq -e . >/dev/null 2>&1 <<<"$input" || exit 0
agent_type=$(jq -r '.tool_input.subagent_type // ""' <<<"$input")
model=$(jq -r '.tool_input.model // ""' <<<"$input")
cwd=$(jq -r '.cwd // ""' <<<"$input")
[ "$agent_type" = "fork" ] && exit 0
[ -n "$model" ] && exit 0

# Does the definition of the agent named $agent_type pin a model (other than inherit)?
definition_pins_model() {
  local file name m
  [ -n "$agent_type" ] || return 1
  for file in "$HOME"/.claude/agents/*.md "$cwd"/.claude/agents/*.md; do
    [ -f "$file" ] || continue
    # first frontmatter block only (between the first and second --- line)
    name=$(awk '/^---[[:space:]]*$/{n++; next} n==1 && /^name:/{sub(/^name:[[:space:]]*/,""); print; exit}' "$file")
    [ "$name" = "$agent_type" ] || continue
    m=$(awk '/^---[[:space:]]*$/{n++; next} n==1 && /^model:/{sub(/^model:[[:space:]]*/,""); print; exit}' "$file")
    [ -n "$m" ] && [ "$m" != "inherit" ] && return 0
  done
  return 1
}
definition_pins_model && exit 0

jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "A subagent without a `model` field would inherit the session model. Pass `model` deliberately: judge for yourself which of the available models this task needs."}}'
