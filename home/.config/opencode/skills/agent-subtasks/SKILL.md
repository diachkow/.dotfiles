---
name: agent-subtasks
description: A skill to spawn child Opencode sessions to effectively use them as subtasks. Only use it when explicitly prompted by user.
---

# Agent Subtasks

The main idea of subtask is to spawn child Opencode session as a separate process and let it execute user-defined task. To create a new subtask, you need the following input from the user, either given explicitly or inferred from the conversation history:

1. **Task** - what to execute in child sessions (subtasks).
2. **Opencode Profile Name** - the user have his own custom setup for running different per-profile configurations for opencode. The name of the current profile is available under `OPENCODE_PROFILE` environment variable. **Always** launch child sessions under the same profile as a parent one.
3. **Model name** - which model to use for the child session. If not specified, use the same model as current (parent) session does.

Once the input is defined, for each subtask create a new `herdr` tab in the current workspace (use `herdr` skill to learn how to do that). Give each tab a short slug name, so they are easy to distinguish.

You mush execute each child session via `oc -p <profile name> [... the rest of opencode CLI arguments ...]`. `oc` command is a custom wrapper to run opencode in profile context. Make sure to use `build` agent for child sessions, so they can invoke necessary commands themselves. Prefix opencode session name with `[subtask]` for better searchability.

**Only when explicitly asked by the user to wait for the subtasks for finish**, run a simple one-time script in a current (parent) session to watch for the subtasks exeecution and poll for their completion status each 30 seconds. The script should end its execution when all child Opencode session have finished their work. Once that has happened, cleanup the `herdr` tabs and report back the execution results to the user.

If you were not prompted to wait for the output, just let the session run in a sibling tab asynchronously until its done. No need to monitor its execution.
