# Claude settings management

`~/.claude/settings.json` is produced by the chezmoi modify template
`modify_settings.json`. It is a Go template, with no custom script.

On `chezmoi apply`, it deep-merges, with later sources winning:

1. the live `~/.claude/settings.json`
2. `.chezmoitemplates/canonical_claude_settings.json` (personal, public)
3. `~/.codex/claude/settings.json` (work, from the private codex-config repo),
   if it exists

Maps merge key by key. Lists such as `hooks` and the sandbox lists are replaced
whole, so the work file carries the complete hook list. `$HOME` is expanded
in the output.

Only keys that appear in a source are managed. Anything Claude writes itself,
such as `model`, `permissions.allow`, `statusLine` and plugin toggles you
change, is left alone. Change the model with `/model`; it won't be overwritten.

On a personal machine there is no codex-config checkout, so only the
canonical settings apply.
