# Ansible dotfiles

My dotfiles in ansible. Shamelessly ripped off from
https://github.com/vwall/ansible-dotfiles

run with `ansible-playbook -ihosts site.yml` from the checkout dir

## Changing / adding repos / symlinks

The file `roles/dotfiles/vars/main.yml` contains a list of repos to check out,
and the destination to check them out to. It also contains a list of symlinks to
create - symlink from the file in the repo to the correct location in the home
directory.

The directory `roles/dotfiles/files/simple` contains a list files that will be
symlinked to the coresponding place in the home directory - `tmux.conf` will end
up in `~/.tmux.conf`

The file `roles/dotfiles/tasks/main.yml` contains some more misc things to be
setup

My git config is templated within here because I use boxen on the mac and I need
mac specific config.

## Vagrant

This includes a Vagrantfile which will set vagrant up to provision with this
repo - so the vagrant user will have all your dotfiles
