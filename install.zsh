#This install script is currently under the assumption you've installed zsh and oh-myzsh.

ln -sfv ~/.profiles/my_cmd.zsh ~/.oh-my-zsh/custom/my_cmd.zsh
ln -sfv ~/.profiles/.zshrc ~/.zshrc

#bash isn't really synced terribly well
ln -sfv ~/.profiles/.bashrc ~/.bashrc
ln -sfv ~/.profiles/.bash_profile ~/.bash_profile

#OS X...should have conditions...meh
ln -sfv ~/.profiles/.profile ~/.profile

