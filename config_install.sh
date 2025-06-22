#!/bin/bash

install_dir="/nvim"

apt update 

apt install tmux git ripgrep

# If neovim is not installed then install it
if ! command -v nvim >/dev/null 2>&1
then
	mkdir -p $install_dir
	wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-arm64.appimage -O $install_dir/nvim.appimage
	chmod u+x $install_dir/nvim.appimage
	(cd $install_dir; ./nvim.appimage --appimage-extract)
	ln -s $install_dir/squashfs-root/usr/bin/nvim /usr/bin/nvim && ln -s $install_dir/squashfs-root/usr/bin/nvim /usr/bin/vim
fi

# Create config directory
config_dir="$HOME/.config"
mkdir -p $config_dir

# Depedencies for treesitter
apt install -y npm build-essential
# apt install -y nodejs # TODO: nodejs should probably be installed another way
echo "Installing tree-sitter-cli"
npm install -g tree-sitter-cli

# Copy configs
cp -v -R $HOME/neovim_dev/config/* $HOME/.config/ 

cp -v -a -r $HOME/neovim_dev/git/. $HOME/

# Add bash configs
$HOME/neovim_dev/bash/extend_bashrc.sh
