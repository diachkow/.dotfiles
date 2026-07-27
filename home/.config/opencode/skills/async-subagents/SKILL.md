---
name: async-subtasks
description: A skill to spawn child Opencode sessions to effectively use them as async subagents. Only use it when explicitly prompted by user.
---

# Async Subtasks

The main idea of asynchronous subtasks is to spawn child Opencode sessions as a separate process and let them execute user-defined task. To create a new asynchronous subagent, you need the following input from the user, either given explicitly or inferred from the conversation history:

1. **Task** - what to execute in child sessions (subagents).
2. **Opencode Profile Name** - the user have his own custom setup for running different per-profile configurations for opencode. The name of the current profile is available under `OPENCODE_PROFILE` environment variable. **Always** launch child sessions under the same profile as a parent one.
3. **Model name** - which model to use for the child session. If not specified, use the same model as current (parent) session does.

Once the input is defined, for each subtask create a new `herdr` tab in the current workspace (use `herdr` skill to learn how to do that). Give each tab a short slug name, so they are easy to distinguish.

You mush execute each child session via `oc -p <profile name> [... the rest of opencode CLI arguments ...]`. `oc` command is a custom wrapper to run opencode in profile context. Make sure to use `build` agent for child sessions, so they can invoke necessary commands themselves.

After launching subtasks, run a command in a current (parent) session to watch for the subtasks execution and poll for their completion status each 30 seconds. Wait until all of them have finished. Once that has happened, report back the execution results to the user.
