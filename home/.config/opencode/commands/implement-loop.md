---
description: "Start agent implementation loop with mentioned plan. Usage: /implement-loop spec.md openai/gpt-5.5 low"
agent: build
---

Implement $1. Prepare a TODO list for yourself and iterate on it, do not stop until finished.

Once you are finished, run the relevant verification commands in the project (linting, type-checking, building dry-run, unit tests etc).

If verifications have passed, run an agent code review as defined in `/agent-code-review` skill with model $2 and variant $3.

After agent code review is conducted, process the output of code review subtasks. If there are any items that can be addressed immediately and they have high relevance and blocking the merge - address them. If you are unsure about the path and you need to interview me first - use Question tool to clarify the implementation step.

At the very end of it, provide a short summary of what you've done.
