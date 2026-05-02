# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles management repository using Ansible and Chezmoi. It automates the setup of a development environment by cloning git repositories, creating symlinks, and managing system configurations across macOS and Ubuntu systems.

## Running the Playbook

```bash
ansible-playbook -ihosts site.yml
```

This runs the main playbook locally (targets 127.0.0.1) with the `dotfiles` role.

Tags for selective runs:
- `dotfiles` — git clone/pull and simple dotfile linking
- `link` — only re-link simple dotfiles
- `sudo` — Ubuntu-only privileged tasks (apt)

```bash
ansible-playbook -ihosts site.yml --tags link
```

## Homebrew (macOS)

```bash
brew bundle
```

Installs packages, casks, and Mac App Store apps defined in `Brewfile`.

## Architecture

This repo has **two dotfile management systems**. Chezmoi is the preferred system for all new dotfiles — do not add new files to the Ansible simple-symlink system.

### Chezmoi (preferred for new dotfiles)

Files in `home/` are managed by chezmoi using its naming conventions (`dot_` prefix = dotfile, `private_` prefix = restricted permissions). The `.chezmoiroot` file points chezmoi at the `home/` subdirectory. This covers zshrc, tmux.conf, nvim config, kitty config, ghostty config, and more.

### Ansible Role (`roles/dotfiles/`)

The Ansible role handles:
- **Git repositories**: Clones repos defined in `roles/dotfiles/vars/main.yml` (`dotfiles.timmow.git.repos`) to specified locations, with SSH push URL transformation.
- **Custom symlinks**: Creates explicit symlinks defined in `dotfiles.timmow.symlinks` in `vars/main.yml`.
- **Simple dotfiles (legacy)**: Files in `roles/dotfiles/files/simple/` are symlinked to `~/.<filename>`. This system is maintained but not extended — use chezmoi for new dotfiles.
- **Platform-specific tasks**: Ubuntu tasks (`ubuntu.yml`, `ubuntu_unprivileged.yml`) run conditionally based on `ansible_os_family`.

The `group_vars/all.yml` file defines `timmow.home` (user home directory path) used throughout the role.

## Chezmoi Workflow

Chezmoi's source directory is at `~/.local/share/chezmoi/`, which is a **separate clone** of this repo (not `~/src/ansible`). Always use `chezmoi add` to add new dotfiles — do not manually create `dot_` files in `~/src/ansible/home/`.

```bash
chezmoi add ~/.some-dotfile

chezmoi git add -- .
chezmoi git commit -- -m "Add some-dotfile"
chezmoi git push
```

Then pull the changes into `~/src/ansible` if needed:

```bash
cd ~/src/ansible && git pull
```

When testing or debugging chezmoi-managed dotfiles, remember that `chezmoi diff`, `chezmoi apply`, and `chezmoi data` operate on the separate source checkout in `~/.local/share/chezmoi/`, not the repo copy in `~/src/ansible`. If you edit files under `~/src/ansible/home/`, sync those changes into `~/.local/share/chezmoi/` before relying on `chezmoi diff` or `chezmoi apply`.

If a chezmoi template depends on host identity, verify the actual values from `chezmoi data` rather than assuming the current machine name. Useful checks:

```bash
chezmoi data | rg 'hostname|fqdnHostname'
hostname
hostname -s
```

On macOS, `ComputerName`, `LocalHostName`, `HostName`, and the shell hostname may differ.

## Testing Changes

After modifying roles or tasks, run the playbook to verify changes. The playbook is idempotent and safe to run multiple times. Check for git repo status before running to avoid uncommitted changes being overwritten (the playbook checks this with `git rev-list "@{upstream}"...HEAD`).
