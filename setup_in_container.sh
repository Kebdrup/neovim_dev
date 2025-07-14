echo "Setting up neovim in $1"

docker exec $1 /bin/bash -c "apt update && apt install git -y; (cd ~; rm -rf ./neovim_dev; git clone https://github.com/Kebdrup/neovim_dev.git; ./neovim_dev/config_install.sh -r)"
