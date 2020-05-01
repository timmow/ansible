setopt no_global_rcs
for ve in rbenv pyenv; do
    if type ${ve} &> /dev/null; then
        eval "$(${ve} init -)"
    fi
done
export GOPATH=~/.go
export PATH="$HOME/.local/bin:$GOPATH/bin:$HOME/bin:/usr/local/sbin:/usr/local/bin:$PATH"
export PATH="$PATH:`npm prefix -g`/bin"
