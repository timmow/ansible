# TODO

## Git config follow-up

- Revisit the global Git rebase defaults in `roles/dotfiles/files/simple/gitconfig`.
- Consider removing:
  - `branch.autosetuprebase = always`
  - `pull.rebase = true`
- Consider replacing the global default with an explicit alias such as:
  - `up = pull --rebase --autostash`

### Rationale

- Both `branch.autosetuprebase` and `pull.rebase` push the same workflow policy: prefer rebasing over merging when pulling.
- Keeping both adds conceptual overlap and makes it less obvious why a given branch rebases on pull.
- Automatic rebasing is convenient on private branches, but it is a worse default once a PR is published and under review.
- Rebasing a reviewed branch rewrites history, which can make it harder for reviewers to see what changed since the last review and can invalidate review context.
- Making rebase explicit keeps the cleaner-history workflow available without normalizing history rewrites on published PR branches.

### Proposed direction

- Keep:
  - `rebase.autosquash = true`
  - `rebase.autoStash = true`
- Remove:
  - `branch.autosetuprebase = always`
  - `pull.rebase = true`
- Add:
  - an explicit alias for rebase-based updating when the branch is still private

## Git signing on other machines

- Git signing is now managed in `home/dot_gitconfig.tmpl` under chezmoi.
- Signing is enabled only for hosts listed in the `signingHosts` allowlist near the bottom of that template.
- To opt a machine in:
  - confirm its hostname with `hostname` and `chezmoi data | rg hostname`
  - add the short hostname and/or FQDN to `signingHosts`
  - run `chezmoi apply`
- On macOS:
  - the template uses 1Password's `op-ssh-sign`
  - the machine should have access to the signing key in the local 1Password SSH agent setup
- On a remote Ubuntu devbox using forwarded SSH agent:
  - use `ssh -A` or `ForwardAgent yes`
  - make sure the forwarded agent exposes the signing key from the Mac
  - after adding the host to `signingHosts`, run `chezmoi apply` on the devbox
- To verify:
  - run `git config --get user.signingkey`
  - run `git config --get commit.gpgsign`
  - run `git commit -S --allow-empty -m "test signing"`
- To back a machine out:
  - remove its hostname from `signingHosts`
  - run `chezmoi apply`

## Python: pyenv → uv migration (started 2026-10-31)

uv now manages Python interpreters and CLI tools; pyenv is being phased out per machine.

- `home/dot_zshrc.tmpl` reads the `python_manager` chezmoi data key. When it is unset it falls back to pyenv, so unflagged machines are unchanged.
- To opt a machine in, add this to its local `~/.config/chezmoi/chezmoi.toml`:
  ```toml
  [data]
      python_manager = "uv"
  ```
  Then run `chezmoi diff ~/.zshrc && chezmoi apply ~/.zshrc`, followed by:
  - `uv python install 3.15 --default --preview-features python-install-default`
  - `pipx uninstall-all`
  - `uv tool install black`, `uv tool install poetry`, `uv tool install neovim-remote --with 'setuptools<81'` (nvr imports `pkg_resources`)
- Status:
  - [x] Personal Mac (`Mac`)
  - [ ] Work laptop
  - [ ] Remote devbox (Linux)
- Roll back a machine: remove the `[data]` key, run `chezmoi apply ~/.zshrc`, open a new shell, then `uv tool uninstall black poetry neovim-remote` and `pipx install` each tool again.
- Final cleanup (only once every machine is on uv, because these are shared and cannot be rolled back per machine):
  - Remove `pipx`, `pyenv` and `pyenv-virtualenvwrapper` from `Brewfile`.
  - Remove the `pyenv` git clone from `roles/dotfiles/vars/main.yml`.
  - `rm -rf ~/.pyenv` on each machine (check for project venvs built on pyenv Pythons first).
  - Delete the pyenv branch and `python_manager` logic from `home/dot_zshrc.tmpl`.
  - Optionally `brew uninstall python@3.10 python@3.11` if nothing depends on them.

## chezmoi: `machine_type` is undefined on the personal Mac

- `home/dot_gitconfig.tmpl` uses `{{ if eq .machine_type "personal" }}`, but nothing defines `machine_type` (there is no `.chezmoi.toml.tmpl`, and the Mac's local config only sets `python_manager`).
- Because chezmoi errors on missing keys, a full `chezmoi apply` or any apply touching `~/.gitconfig` fails on this machine.
- Fix: either add `machine_type = "personal"` to each machine's local `[data]`, or add a `.chezmoi.toml.tmpl` that prompts for it (`promptStringOnce`).
- The "Git signing on other machines" section above describes the older `signingHosts` allowlist and is now stale. Update it once `machine_type` is settled.

## Repo clones out of sync

- `~/src/ansible` is 11 commits behind `origin/master` and has uncommitted edits (`home/dot_zinitrc`, `home/dot_zshrc`, `roles/dotfiles/files/simple/zshenv`, plus an untracked `home/dot_zshrc.orig`).
- Reconcile those edits into the chezmoi clone (or discard them), then `git pull`.

## Avoid bare `chezmoi apply`

- A bare `chezmoi apply` also runs the `~/.claude/settings.json` modify script and touches every other managed file.
- When changing one dotfile, diff and apply it by name: `chezmoi diff <file>` then `chezmoi apply <file>`.
