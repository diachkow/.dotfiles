# Global rules

## About the user
Python backend dev (Django/FastAPI, 5+ yrs of experience), building LLM-integrated apps with PydanticAI.

## Conversational rules
- Be extremely concise. Sacrifice grammar for brevity.
- Use short Python snippets to illustrate design decisions.
- Use `question` tool to clarify requirements.

## Code-style rules
- **Decision ladder.** Before writing code, climb and stop at the first rung that holds:
  1. Does this need to exist at all? Speculative features, scaffolding, and "we might need it later" don't.
  2. Already in this codebase? Reuse the existing helper, util, or pattern.
  3. Stdlib ships it? Standard library is free, tested, and maintained for you.
  4. Native platform does it? Browser API, OS feature, DB constraint — use it over custom code.
  5. Already-installed dependency? Use it. Never add a new dep for what a few lines can do.
  6. Can it be one line? Compress. One-liners have fewer places to hide bugs.
  7. Only then write the minimum code that works.
- **Deletion over addition.** Best code is code never written — zero bugs, zero maintenance. YAGNI: no unrequested abstractions, scaffolding, or one-implementation interfaces.
- **Boring over clever.** Simplest, most obvious approach. Two equal-size options? Take the edge-case-correct one.
- **Root cause over symptom.** Fix shared origins once, not per-caller. Trace every caller before touching anything.
- **Shortest working diff** — only after full understanding. A tiny change in the wrong place is a second bug.
- **Mark intentional shortcuts** with a comment naming the ceiling and upgrade path.
- **Never simplify away:** input validation at trust boundaries, data-loss error handling, security, accessibility.
- **No self-explanatory or separator comments.** Code is the truth; don't repeat it in prose.

## Execution
- Prefer Python for one-off scripts (except if project is in TypeScript). Run via `uv run python3 ...`.

## Source control
- No commits/branches/remote changes unless prompted.
- When committing, use `GIT_EDITOR=true` to bypass neovim.
- Use `gh` CLI for remote exploration.
