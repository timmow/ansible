# Claude Settings Management

Manages `~/.claude/settings.json` across multiple machines using chezmoi's
`modify_` script. The modify script merges two JSON source files and the
existing live file, then expands `$HOME` placeholders.

## How it works

```
.chezmoitemplates/canonical_claude_settings.json   (public, this repo)
~/.cache/claude-work-settings/settings.json        (private repo, cloned locally)
~/.claude/settings.json                            (live file, read as base)
```

On `chezmoi apply`, the modify script:
1. Deep-merges canonical over current (canonical wins)
2. Deep-merges work over result (work wins)
3. Unions `permissions.allow` from all three sources (nothing lost)
4. Expands `$HOME` placeholders in the output

Source files use the same schema as `settings.json` itself, with `$HOME`
for machine-specific paths.

## Workflow

Edit the source files directly:
- Canonical (public): `~/.local/share/chezmoi/home/.chezmoitemplates/canonical_claude_settings.json`
- Work (private): `~/.cache/claude-work-settings/settings.json`

Then commit and push each repo. On other machines, pull and `chezmoi apply`.

If Claude Code adds a new permission interactively, it goes into the live
file. Next time you want to persist it, add it to the appropriate source
file. The permission won't be lost between applies since the union keeps
everything in the live file.

## Machine setup

Work machines need the private repo cloned to `~/.cache/claude-work-settings/`.

Personal machines just skip work settings (the file won't exist).
