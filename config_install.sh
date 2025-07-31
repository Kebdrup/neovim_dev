#!/bin/bash

install_dir="/nvim"

setup_container() {
  # Update and install dependencies
  apt update 
  apt install tmux git ripgrep

  # Install python
  apt install -y python3 python3-venv

  # Install nodejs
  sudo apt install -y curl
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  sudo apt install -y nodejs

  # If neovim is not installed then install it
  if ! command -v nvim >/dev/null 2>&1
  then
    mkdir -p $install_dir
    wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-arm64.appimage -O $install_dir/nvim.appimage
    chmod u+x $install_dir/nvim.appimage
    (cd $install_dir; ./nvim.appimage --appimage-extract)
    ln -s $install_dir/squashfs-root/usr/bin/nvim /usr/bin/nvim && ln -s $install_dir/squashfs-root/usr/bin/nvim /usr/bin/vim
  fi

  # Depedencies for treesitter
  apt install -y npm build-essential
  # apt install -y nodejs # TODO: nodejs should probably be installed another way
  echo "Installing tree-sitter-cli"
  npm install -g tree-sitter-cli

  # Add git config
  cp -v -a -r $HOME/neovim_dev/git/. $HOME/

  # Add bash configs
  $HOME/neovim_dev/bash/extend_bashrc.sh

}

remote=false

# Parse options
while getopts 'r' opt; do
  case "$opt" in
    r) setup_container; remote=true;;
  esac
done
shift $((OPTIND -1))


# Create config directory
config_dir="$HOME/.config"

if [ "$1" == "" ] || [ $# -gt 1 ]; then
  echo "No config directory provided, using: $config_dir"
else
  config_dir="$1"
  echo "Using config directory: $config_dir"
fi

mkdir -p $config_dir

# Copy configs
if $remote; then
  cp -v -R $HOME/neovim_dev/config/* $config_dir 
else
  cp -v -R ./config/* $config_dir 
fi

