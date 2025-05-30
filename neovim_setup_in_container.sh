echo "Setting up neovim in $1"

docker exec $1 /bin/bash -c "apt update && apt install git -y; (cd ~; git clone https://github.com/Kebdrup/neovim_dev.git; ./neovim_dev/neovim_install.sh)"
