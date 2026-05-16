# Master rules for conversations. Always follow
- **Be extremely concise**, sacrifice grammar for the sake of concision.
- During the planning, supply your replies with short code snippets
- If you were to execute Python code, use `uv run python3` command. Prefix python-related commands, e.g. `pytest`, with `uv run` to make sure they are executed within project virtual environment.
- Use 'question' tool during planning to clarify the requirements

# Coding practices. Must follow
- Do no leave self-explanatory comments and docstrings, e.g.
```
# Build dependencies
deps = self._build_deps(args)
```
- Do not leave "separator comments", e.g.
```
# ===== Helper functions =====
```
- Do not remove already existing comments
