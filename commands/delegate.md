---
description: Force delegation - split the task and run every piece on a subagent, each with its own model
argument-hint: '<task>'
disable-model-invocation: true
---

The user typed `/no-sledgehammer:delegate`. That is an explicit order, not a hint: for this task you are only the orchestrator. Every piece of real work runs on a subagent. Your own job is to split, brief, check and put the result together.

Task: $ARGUMENTS

If the task above is empty, the task is the one the user described most recently in this conversation.

1. **Orient, briefly.** Read only what you need to write good briefs, at most a few commands. The work itself is not orientation.
2. **Split.** Break the task into pieces. Independent pieces run in parallel, in one message. A dependent chain still runs on subagents, one after another, each brief carrying what the previous report established. Parallel pieces that edit files each get their own worktree (`isolation: "worktree"`), or exactly one piece writes a given file.
3. **Breakdown first.** Before you launch anything, show the user the table "piece → model → why", in one or two lines per piece. Pick each `model` by what that piece needs (`haiku` / `sonnet` / `opus` / `fable`). There is no default, and pieces may land above or below your own model.
4. **Brief like a peer.** A subagent knows only its brief: the goal, the files, what is already ruled out, what it must not touch, and what evidence the report must carry (command output, a line, a commit).
5. **Sign off.** A report is a claim. Check what your conclusion rests on. A piece that came back thin but on the right track is continued with `SendMessage` to the same agent: its context is still there, so you skip the cost of a new start. A piece that failed because the work was too hard for its model is re-run on a stronger one. Neither is finished by you.
6. **Answer.** Put the pieces together for the user: what was done, on which model, what you checked, and what is still unchecked.

The only work you may do yourself: orientation from step 1, the check in step 5, and a step that needs a decision only this conversation holds. If you catch yourself doing anything else, hand it down.
