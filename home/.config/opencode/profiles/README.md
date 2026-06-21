# opencode profiles

Layered opencode configurations selected at launch time via the `oc` wrapper.

## How it works

opencode reads its config from `~/.config/opencode/` (global). Setting the
`OPENCODE_CONFIG_DIR` env var points opencode at an **additional** directory
that layers **on top of** the global one — it does not replace it. Profiles
carry only the delta (profile-specific agents, skills, plugins, and optional
`opencode.jsonc` overrides); everything else is inherited from the global
config.

Precedence (later wins for conflicting keys):

1. Global `~/.config/opencode/opencode.jsonc`
2. `OPENCODE_CONFIG_DIR` profile directory (agents/skills/plugins auto-scanned,
   `opencode.jsonc` merged on top)

Reference: <https://opencode.ai/docs/config#custom-directory>

## Layout

```
home/.config/opencode/
├── opencode.jsonc          # global config (inherited by every profile)
├── agents/                 # global agents (inherited by every profile)
├── skills/                 # global skills (inherited by every profile)
├── plugins/                # global plugins (inherited by every profile)
└── profiles/
    ├── <name>/
    │   ├── profile.yaml    # required: description + optional env vars for `oc`
    │   ├── opencode.jsonc  # optional: profile-specific overrides
    │   ├── agents/         # optional: profile-specific agents
    │   ├── skills/         # optional: profile-specific skills
    │   └── plugins/        # optional: profile-specific plugins
    └── ...
```

After stow, this tree is symlinked into `~/.config/opencode/`, so profiles live
at `~/.config/opencode/profiles/<name>/`.

## The `oc` wrapper

`home/.local/bin/oc` (on `$PATH` after stow) selects a profile and forwards all
remaining args to `opencode`:

```
oc -p <profile> [opencode args...]
```

- No args / missing `-p` → prints usage plus the list of available profiles
  (reading each profile's `profile.yaml` `description` field).
- Unknown profile → error with a hint to run `oc` for the list.

Example: `oc -p tutor` launches the TUI with the `tutor` profile active.
Example: `oc -p tutor run "explain monads"` forwards the `run` subcommand.

`oc` is a Python script launched via a `uv run --script` shebang with PEP 723
inline dependencies (`typer`, `pyyaml`). First invocation may briefly fetch
those packages into uv's ephemeral environment; subsequent runs are cached.

`oc` exports `OPENCODE_PROFILE` to the opencode process, set to the selected
profile's directory name (e.g. `tutor`). It's available to any tool that
reads the environment. When launched outside `oc` (plain `opencode`), the
var is unset.

## The `profile.yaml` convention

Every profile **must** contain a `profile.yaml` file. Its schema:

```yaml
description: <string, mandatory>      # one-liner shown by `oc` listing
environment:                           # optional mapping of env vars to set
  LITERAL_NUM: 1                       # any scalar -> str()
  LITERAL_STR: "1"
  LITERAL_BOOL: true
  FROM_FILE: {file: ~/.secrets/x.txt} # read file, .strip()'d
  BLOCK_FORM:                          # block mapping equivalent of {file: ...}
    file: ~/.secrets/x.txt
```

Rules:

- `description` is mandatory and must be a string. `oc` errors out if missing.
- `environment` is optional. When present, it's a mapping of `VAR: value`.
- Each value is either:
  1. a literal scalar (str/int/float/bool) — coerced to `str()` and exported, or
  2. a mapping with exactly one key `file` whose value is a path — the file is
     read, `.strip()`'d, and the result exported.
- File-ref paths run through `os.path.expanduser` (`~` → home) and
  `os.path.expandvars` (`$VAR` expansion) before reading.
- A missing `profile.yaml` (or missing `description`) makes `oc` refuse to
  launch or list that profile. There is no fallback to `.description`.

`profile.yaml` is inert to opencode's own config scanner (it only looks for
`opencode.json(c)`, `agents/`, `skills/`, `plugins/`), so it never affects
opencode startup — it's consumed solely by `oc`.

Worked example — the `tutor` profile enables the `websearch` tool:

```yaml
# profiles/tutor/profile.yaml
description: Tutoring agent for learning new technologies and techniques
environment:
  OPENCODE_ENABLE_EXA: "1"
```

Worked example — reading an API key from a secrets file:

```yaml
# profiles/work/profile.yaml
description: Corporate work-related projects
environment:
  OPENCODE_API_KEY: {file: ~/.secrets/opencode-work-key.txt}
```

## Adding a new profile

1. Create `home/.config/opencode/profiles/<name>/`.
2. Add `profile.yaml` with at least a `description` field (and optional
   `environment` mapping — see "The `profile.yaml` convention" above).
3. Optionally add `opencode.jsonc` with overrides (e.g. `default_agent`,
   `permission`, `agent.<builtin>.disable`, `enabled_providers`).
4. Optionally add `agents/`, `skills/`, `plugins/` subdirs for profile-specific
   resources.
5. Run `./scripts/restow.sh` (only needed if a new top-level entry appears
   under a stowed dir; the `profiles/` dir itself is already stowed as part of
   `~/.config/opencode`, so new profiles appear automatically without restow).
6. Launch with `oc -p <name>`.

## Notes

- opencode loads config once at startup. After editing any profile file, quit
  and restart `oc -p <name>` for changes to take effect.
- Because profiles layer on top of global, a profile can override a global
  agent by defining the same key in its `opencode.jsonc` `agent:` block, or
  disable a built-in via `agent: { build: { disable: true } }`.
- `enabled_providers` (allowlist) and `disabled_providers` (blocklist) are
  supported overrides. On merge, a profile's value **replaces** the global
  value rather than unioning with it — so a profile listing `enabled_providers`
  exposes only those providers for that launch. The global config sets
  `enabled_providers: ["opencode", "opencode-go"]` (Zen + Go) as the personal
  default; the `work` profile overrides it with `["openai", "github-copilot"]`.
