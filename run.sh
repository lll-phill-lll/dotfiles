# install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# create symlink to vimrc
ln -n .vimrc ~/.vimrc
#install plugins
vim +PlugInstall +qall > /dev/null

#install tmux
sudo apt install tmux
# create a symlin to tmux.conf
ln -n .tmux.conf ~/.tmux.conf
