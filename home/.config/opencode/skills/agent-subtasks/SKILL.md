---
name: agent-subtasks
description: A skill to spawn child Opencode sessions to effectively use them as subtasks. Only use it when explicitly prompted by user. DO NOT read it if you are a subtask agent.
---

# Agent Subtasks

Spawn child Opencode sessions as separate processes (via Herdr tabs) to execute user-defined work in parallel.

**Do not use this skill if you are yourself a subtask agent.**

## Required input

Gather from the user or conversation history:

1. **Task(s)** — what each child session must do.
2. **Opencode profile** — always the parent profile (`OPENCODE_PROFILE`). Launch children with the same profile.
3. **Model** — child model; default to the parent session's model if unspecified. Include `--variant` when a reasoning level is required (e.g. `xhigh`).

## Launch workflow (Herdr)

Commands below are enough for the normal subtask path. Load the `herdr` skill **only** if you hit a gap (unknown flag, layout change, agent rename, etc.).

Requires `HERDR_ENV=1`. Capture **all IDs from Herdr JSON** — never guess workspace/tab/pane IDs.

### 1. Current context

```bash
herdr pane current --current
```

Read `workspace` ID (and caller pane/tab if needed) from the JSON.

### 2. Background tab per subtask

Create tabs without stealing focus. Save returned **tab** and **root pane** IDs.

```bash
herdr tab create --workspace <workspace-id> --cwd "$PWD" --label "<short-label>" --no-focus
```

Independent subtasks → create and start tabs **concurrently**.

### 3. Start OpenCode in the root pane

```bash
herdr pane run <pane-id> "oc -p <profile> run --agent build --model <model> --variant <reasoning-level> --title '[subtask] <title>' '<detailed-prompt>'"
```

Rules:

- Always `oc -p <profile>` (profile wrapper), never bare `opencode`.
- Always `--agent build` so the child can run tools/commands.
- Prefix session title with `[subtask]` for searchability.
- Example model flags: `--model openai/gpt-5.6-luna --variant xhigh`.
- Part of your prompt to child subagent should be an instruction that they **SHOULD NOT** launch any subagents or subtasks of their own as they are already a subtask. Creating more deep, nested graph will lead to overuse of the tokens, so it is very important to comply with this rule!

### 4. Prompt contract

Every child prompt must be **self-contained**. Include:

- Exact task and scope (what to edit / not edit).
- Allowed and prohibited paths (e.g. no `.env` / credential reads unless required).
- Required verification steps.
- **Expected report path** (artifact the parent will read).
- **Final response format** (what to write in the report and terminal).

Require the child to finish with available evidence even if optional evidence is missing — do not die on blocked optional reads.

### 5. Confirm startup

A subtask is not “launched” until startup is verified:

```bash
herdr pane read <pane-id> --source recent-unwrapped --lines 40
herdr agent list
```

Check: requested model appears; agent entered `working` (or equivalent live state). Fix launch failures before moving on.

## Tracking progress

### Default: do not poll

If the user did **not** ask to wait, leave siblings running asynchronously. Do not monitor.

### When the user asks to wait

Run **one** polling loop; check every pane every ~30s. Stop when none are still active.

Active states (still running): `working`, `blocked`, `idle`.

```bash
while true; do
  all_done=1
  for pane in <pane-1> <pane-2> <pane-3>; do
    state=$(herdr pane get "$pane" | jq -r '.result.pane.agent_status // "unknown"')
    if [ "$state" = "working" ] || [ "$state" = "blocked" ] || [ "$state" = "idle" ]; then
      all_done=0
    fi
  done
  [ "$all_done" -eq 1 ] && break
  sleep 30
done
```

### Interpret states correctly

| State | Meaning for parent |
| --- | --- |
| `working` / `blocked` / `idle` | Still in progress — keep waiting |
| `done` | Likely finished — still **verify artifacts** |
| `unknown` | **Inspect the pane** — not success, not automatic failure |

`unknown` often means the process exited oddly, permissions rejected, or Herdr lost classification. Always:

```bash
herdr pane read <pane-id> --source recent-unwrapped --lines 100
```

and check whether the **expected report file exists**.

### Verify artifacts after exit

Process exit alone is insufficient. For each subtask:

1. Read pane output (`herdr pane read ...`).
2. Confirm the contracted report path exists and is usable.
3. Mark failed if: state is `unknown` with no report, report missing, or pane shows rejected/prohibited actions that aborted work.

## Retry

Relaunch **only failed** subtasks — prefer the **existing** pane.

- Tighten the prompt (e.g. if your original prompt caused subagent to bump into permission error).
- Require completion with available evidence when optional paths are blocked.
- Re-confirm startup; re-verify the report artifact.

Do not restart successful siblings.

## Cleanup and report

After all expected reports exist (or failures are accepted):

1. Consolidate findings from report files (+ pane tails if needed).
2. Close **only tabs this parent created**:

```bash
herdr tab close <tab-id>
```

3. Report consolidated results to the user.

Never close the user's original tab/pane or tabs you did not create.
