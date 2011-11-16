#This install script is currently under the assumption you've installed zsh and oh-myzsh.

ln -sfv my_cmd.zsh ~/.oh-my-zsh/custom/my_cmd.zsh
ln -sfv .zshrc ~/.zshrc

#bash isn't really synced terribly well
ln -sfv .bashrc ~/.bashrc
ln -sfv .bash_profile ~/.bash_profile

#OS X...should have conditions...meh
ln -sfv .profile ~/.profile

