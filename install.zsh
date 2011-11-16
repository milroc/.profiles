#This install script is currently under the assumption you've installed zsh and oh-my-zsh.

ln -sfv ~/.profiles/my_cmd.zsh ~/.oh-my-zsh/custom/my_cmd.zsh
ln -sfv ~/.profiles/.zshrc ~/.zshrc

#writing this in a zsh script seems stupid...
if [ ~/.bashrc ]; then
	rm -rf ~/.bashrc
fi
touch ~/.bashrc	
echo "export TERM=\"xterm-color\"\n export PS1=\"\[\e[1;32m\]\w\[\e[0m\]: \"\nif [ -f ~/.profiles/.alias ]; then\n    source ~/.profiles/.alias\nfi\n" >> ~/.bashrc
source ~/.bashrc

ln -sfv ~/.profiles/.bash_profile ~/.bash_profile



#OS X...should have conditions...meh
ln -sfv ~/.profiles/.profile ~/.profile

