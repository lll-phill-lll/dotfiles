if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

. "$HOME/.atuin/bin/env"
. "$HOME/.cargo/env"
