#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function update() {
clear
logo
printGreen "Завантаження залежностей"
sudo apt update && sudo apt install pkg-config libssl-dev libzstd-dev protobuf-compiler -y
#sudo add-apt-repository ppa:deadsnakes/ppa -y
#sudo apt update && sudo apt install curl git tmux python3.10 python3.10-venv python3.10-dev build-essential libgmp-dev pkg-config libssl-dev -y
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
source $HOME/.bash_profile
rustup update stable --force

cd ~/pathfinder
git pull
git fetch --all
git checkout v0.10.3
cargo build --release --bin pathfinder
sudo mv ~/pathfinder/target/release/pathfinder /usr/local/bin/
mkdir -p $HOME/.starknet/db

echo "[Unit]
Description=StarkNet
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url \"$ALCHEMY\" --data-directory \"$HOME/.starknet/db\"
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/starknetd.service
sudo mv $HOME/starknetd.service /etc/systemd/system/

#cd py
#python3.10 -m venv .venv
#source .venv/bin/activate
#PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
#pip install --upgrade pip
sudo systemctl daemon-reload
sudo systemctl restart starknetd
echo "==========================================="
printGreen  "Нода оновлена і запущена"
printGreen "Перевірити версію ноди: pathfinder -V"
printGreen "Перевірити журнал логів: journalctl -u starknetd -f
"
echo "==========================================="
}
update
