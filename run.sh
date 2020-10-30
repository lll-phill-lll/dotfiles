# install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# create symlink to vimrc
ln -s .vimrc ~/.vimrc
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

#install tmux
sudo apt install tmux
# create a symlink to tmux.conf
ln -s .tmux.conf ~/.tmux.conf
