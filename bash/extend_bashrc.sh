#!/bin/sh

# Expand_aliases 
shopt -s expand_aliases
source "$HOME/.bashrc"

add_alias () {
  if alias $1 >/dev/null 2>&1; then 
    echo "$1 already exists"
  else 
    echo "Adding $1='$2' to .bashrc"
    echo "alias $1='$2'" >> "$HOME/.bashrc"
  fi
}

add_alias 'vsp' 'tmux split-window -v'
add_alias 'sp' 'tmux split-window -h'
add_alias 'll' 'ls -la'

source "$HOME/.bashrc"
