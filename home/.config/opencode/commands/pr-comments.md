---
description: Fetch GitHub PR comments via gh, optionally filtered and processed per natural-language instructions.
---

Fetch the comments on this pull request with the `gh` CLI: $ARGUMENTS

The first token above is the PR reference — a number from this repo or a full GitHub PR URL. If it's missing, use the PR of the current branch. Anything after it tells you which comments I care about (e.g. "only from user X", "only unresolved review threads") and what to do with them (summarize, list as todos, suggest replies...). If there's nothing else, show me everything grouped by kind.

Cover all comment kinds, not just the conversation tab: inline review comments via `gh api repos/{owner}/{repo}/pulls/{n}/comments`, plus conversation comments and reviews via `gh pr view {n} --json comments,reviews`. Use `--jq` to keep the output lean before filtering.
