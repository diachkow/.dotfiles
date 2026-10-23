# Global rules

## About the user

You are talking to an experienced Python backend developer: 5+ years building production systems with Django and FastAPI, now focused on applications that integrate LLMs via PydanticAI. Assume familiarity with Python ecosystem conventions, async patterns, type hints, dependency injection, and database design. Do not explain Python basics — explain what is novel, non-obvious, or specific to the codebase at hand.

## Conversational rules

These govern how you communicate. Brevity is a form of respect — the user is a developer, not a tourist. Get to the point.

- **Be extremely concise.** Sacrifice grammar for the sake of concision. Every word you output costs the user attention. If a one-word answer suffices, use it. If three lines suffice, don't write seven. Do not preamble your responses with "I'll do X" or "Let me explain Y" — just do X, just explain Y. Do not summarize what you've done after doing it unless asked. The default mode is: tool output speaks for itself. Your text competes with code — make it earn its place.

- **Use short Python snippets to illustrate design decisions.** When explaining a tradeoff, showing a pattern, or suggesting an approach, use Python code — even if the project isn't Python. Python is the lingua franca of backend engineering; it reads like executable pseudocode. A four-line snippet communicates more clearly than a paragraph of prose. Show, don't tell.

- **Use the `question` tool to clarify requirements before acting.** Ambiguity is the root of rework. If the request could be interpreted in more than one way, stop and ask. Do not assume the user meant the simplest interpretation just because it's the simplest — they might have meant the other one. One clarifying question up front saves an entire round-trip of rewriting.

- **Use plain URLs and file paths, never Markdown hyperlinks.** The user cannot click on hyperlinks in the terminal, so provide them fully for easy copy-and-paste.

## Execution rules

- **Python first.** Prefer Python over shell scripting for one-off tasks, unless the project uses TypeScript. Python has a richer stdlib and fewer footguns than bash. If you're writing an `if` in a shell pipeline, stop — that should be Python.
- **Run via `uv run`.** Always prefix Python commands with `uv run` (e.g., `uv run python3`, `uv run pytest`). Never call `python` or `pip` directly — use `uv pip` or `uv add` instead.

## Source control rules

- **No unprompted mutations.** Do not commit, push, branch, tag, merge, rebase, or create PRs without an explicit prompt. Staging files is fine as part of a requested workflow, but never commit without instruction.
- **`GIT_EDITOR=true` for commits.** The user's default editor is neovim, which hangs in non-interactive sessions. Always set `GIT_EDITOR=true` when committing or rebasing.
- **`gh` CLI for GitHub.** Use `gh` for exploring repos, issues, PRs, and releases — not curl or the browser.
- Do not clone repositories to the tmp path. User's setup is configured to use right credentials only under `~/coding/work/sumup/`. Explore the already-existing repositories there first before cloning a new one there.
