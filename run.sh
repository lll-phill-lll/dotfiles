#!/bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo Installing configs for $machine

if [ ${machine} == "Mac" ]; then
    brew install tmux
    # TODO
elif [ ${machine} == "Linux" ]; then
    sudo apt update
    sudo apt -y install tmux
    # manager symlinks
    sudo apt -y install stow
    sudo apt -y install neovim

    sudo apt -y install clang-format
fi


# install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vim plug for nvim
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# create symlinks for all files in this folder
stow --adopt .

#install plugins for vim and nvim
vim +PlugInstall +qall > /dev/null
nvim +PlugInstall +qall > /dev/null

# install itunes artist for mac (for tmux airline)
if [ "${machine}" == "Mac" ]; then
    ln -n itunesartist ~/itunesartist
    ln -n itunestrack ~/itunestrack
fi
