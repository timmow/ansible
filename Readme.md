# Ansible dotfiles

My dotfiles. Originally ripped off from
https://github.com/vwall/ansible-dotfiles

There are two systems in here:

- **chezmoi** — manages most dotfiles, and is the one to use for anything new.
- **ansible** — clones git repos, creates a few explicit symlinks, and handles
  OS-specific setup.

## chezmoi

`.chezmoiroot` points chezmoi at the `home/` subdirectory, so everything under
`home/` is a chezmoi source file using its naming conventions (`dot_` prefix for
a dotfile, `private_` for restricted permissions, `.tmpl` suffix for a
template). This covers zshrc, tmux.conf, gitconfig, nvim, kitty, ghostty and
more.

Note that chezmoi's source directory is `~/.local/share/chezmoi/`, which is a
*separate* clone of this repo. Add new dotfiles with `chezmoi add ~/.thing`
rather than hand-writing `dot_` files here.

## ansible

run with `ansible-playbook -ihosts site.yml` from the checkout dir

Useful tags: `dotfiles` (git clone/pull plus linking), `link` (relink only),
`sudo` (Ubuntu apt tasks).

### Changing / adding repos / symlinks

The file `roles/dotfiles/vars/main.yml` contains a list of repos to check out,
and the destination to check them out to. It also contains a list of symlinks to
create - symlink from the file in the repo to the correct location in the home
directory.

The directory `roles/dotfiles/files/simple` contains files that will be
symlinked to the corresponding place in the home directory - `ackrc` will end
up in `~/.ackrc`. This is the older system; new dotfiles should go in chezmoi
instead.

The file `roles/dotfiles/tasks/main.yml` contains some more misc things to be
setup

Note that the simple-dotfile linking task expects this repo to be checked out at
`~/src/ansible`, since that path is baked into the symlink source.

## Homebrew

`brew bundle` installs the packages, casks and Mac App Store apps listed in
`Brewfile`.

## Vagrant

This includes a Vagrantfile which will set vagrant up to provision with this
repo - so the vagrant user will have all your dotfiles
