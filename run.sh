unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac


# install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# create symlink to vimrc
ln -n .vimrc ~/.vimrc
#install plugins
vim +PlugInstall +qall > /dev/null
# install russian mac keymap
mkdir -p ~/.vim/keymap
wget https://github.com/vim/vim/blob/master/runtime/keymap/russian-jcukenmac.vim -P ~/.vim/keymap

# install punctuation rules for ru/en
mkdir -p ~/.vim/spell
wget http://ftp.vim.org/vim/runtime/spell/ru.koi8-r.sug -P ~/.vim/spell
wget http://ftp.vim.org/vim/runtime/spell/ru.koi8-r.spl -P ~/.vim/spell
wget http://ftp.vim.org/vim/runtime/spell/en.ascii.sug -P ~/.vim/spell
wget http://ftp.vim.org/vim/runtime/spell/en.ascii.spl -P ~/.vim/spell

# install custom colorsheme from .gl files
mkdir -p ~/.vim/syntax
mkdir -p ~/.vim/ftdetect
ln -n ft_goals.vim ~/.vim/ftdetect/goals.vim
ln -n syn_goals.vim ~/.vim/syntax/goals.vim

#install tmux
if [ ${machine} == "Mac" ]; then
    brew install tmux
elif [ ${machine} == "Linux" ]; then
    sudo apt install tmux
fi
sudo apt install clang-format-13
# create a symlink to tmux.conf
ln -n .tmux.conf ~/.tmux.conf

# install itunes artist for mac (for tmux airline)
if [ ${machine} == "Mac" ]; then
    ln -n itunesartist ~/itunesartist
    ln -n itunestrack ~/itunestrack
fi
