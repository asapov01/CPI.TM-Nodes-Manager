#!/bin/bash

function logo() {
  curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh | bash
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi

printGreen "Введіть URL вашого https APIKEY для змінної:"
read ALCHEMY
echo 'export ALCHEMY='"$ALCHEMY" >> $HOME/.bash_profile

sleep 2
#sudo apt update && sudo apt-get install software-properties-common -y
#sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update && sudo apt install curl git tmux build-essential libgmp-dev pkg-config libssl-dev libzstd-dev protobuf-compiler -y
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup update stable --force
mkdir -p $HOME/.starknet/db
cd $HOME
rm -rf pathfinder
git clone https://github.com/eqlabs/pathfinder.git
cd pathfinder
git fetch
git checkout v0.10.3
#cd $HOME/pathfinder/py
#python3.10 -m venv .venv
#source .venv/bin/activate
#PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
#PIP_REQUIRE_VIRTUALENV=true pip install -e .[dev]
#pip install --upgrade pip
#pytest
#cd $HOME/pathfinder/
#cargo +stable build --release --bin pathfinder
cargo build --release --bin pathfinder
sleep 2
source $HOME/.bash_profile
sudo mv ~/pathfinder/target/release/pathfinder /usr/local/bin/ || exit

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
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable starknetd
sudo systemctl restart starknetd
echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service starknetd status | grep active` =~ "running" ]]; then
  echo -e "Your StarkNet node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice starknetd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your StarkNet node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
}

logo
install
