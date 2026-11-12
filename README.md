# no-sledgehammer

Claude Code plugin: subagents do not silently run on the session model. The orchestrator picks a model for every subtask.

- `hooks/agent-model-required.sh`: PreToolUse on `Agent|Task`; rejects a call without a `model` field.
  Passes `fork` and agent types whose definition pins a model.
- `hooks/session-start.sh`: injects `rules/rules.md` into the context (start, `/clear`, compaction).
- `commands/sub.md`: `/sub <task>` forces delegation. The session only splits, briefs, checks and assembles;
  every piece of work runs on a subagent with a model picked for that piece. User-invoked only.

## Principle: physics, not behavior

The hook only makes sure a model choice is made. It never says which model fits which task:
no roles, no agent definitions, no "model → task" tables.

## Install

```
claude plugin marketplace add emilszymecki/no-sledgehammer
claude plugin install no-sledgehammer@no-sledgehammer
```

Restart the session afterwards: hooks load at session start.

## What the plugin cannot do

A plugin cannot set environment variables (only `agent` and `subagentStatusLine` are honored
from plugin settings). Workflows and built-ins like `/code-review` start subagents outside the
hook, so set the safety net yourself in your settings:

```json
{ "env": { "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet" } }
```

`sonnet` is an example. Set whichever model you want those subagents to fall back to.

The token figures in the rules were measured on Claude Code 2.1.322 (November 2026); they are orders of magnitude, not constants. The criteria for what pays to delegate follow Anthropic's
[Optimizing for cost and intelligence](https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence).

## Dry-run the hook

```
echo '{"tool_input":{"subagent_type":"general-purpose","prompt":"x"},"cwd":"/tmp"}' \
  | hooks/agent-model-required.sh      # -> permissionDecision: deny
echo '{"tool_input":{"subagent_type":"general-purpose","model":"haiku"},"cwd":"/tmp"}' \
  | hooks/agent-model-required.sh      # -> empty output, exit 0
```

## License

MIT
