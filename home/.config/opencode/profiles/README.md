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
    │   ├── opencode.jsonc  # optional: profile-specific overrides
    │   ├── .description    # optional: one-line description for `oc` usage
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
  (reading each profile's `.description` first line).
- Unknown profile → error with a hint to run `oc` for the list.

Example: `oc -p tutor` launches the TUI with the `tutor` profile active.
Example: `oc -p tutor run "explain monads"` forwards the `run` subcommand.

## The `.description` convention

A profile may contain a `.description` file whose first line is a short
one-liner. `oc` reads it for the no-args profile list. The file is inert to
opencode's config scanner (it only looks for `opencode.json(c)`, `agents/`,
`skills/`, `plugins/`), so it never affects startup. Profiles without one
just show an empty description column.

## Adding a new profile

1. Create `home/.config/opencode/profiles/<name>/`.
2. Optionally add `opencode.jsonc` with overrides (e.g. `default_agent`,
   `permission`, `agent.<builtin>.disable`).
3. Optionally add `.description` (one line).
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
