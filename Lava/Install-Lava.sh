#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {
  clear
  source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

  printGreen "Введіть ім'я для вашої ноди(Наприклад:Oliver):"
  read -r NODE_MONIKER

  CHAIN_ID="lava-testnet-2"
  CHAIN_DENOM="ulava"
  BINARY_NAME="lavad"
  BINARY_VERSION_TAG="v0.33.0"
  printGreen "Встановлення необхідних залежностей"
  sudo apt update
  sudo apt install -y curl git jq lz4 build-essential unzip && apt install lz4

  bash <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source .bash_profile

  printGreen "Встановлення Lava"
  export LAVA_BINARY=lavad

  cd || return
  rm -rf lava
  git clone https://github.com/lavanet/lava
  cd lava || return
  git checkout v0.33.0
  make install

  lavad config keyring-backend test
  lavad config chain-id $CHAIN_ID
  lavad init "$NODE_MONIKER" --chain-id $CHAIN_ID

  curl -s https://raw.githubusercontent.com/lavanet/lava-config/main/testnet-2/genesis_json/genesis.json > $HOME/.lava/config/genesis.json
  curl -s https://snapshots-testnet.nodejumper.io/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json

  SEEDS="3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@testnet2-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@testnet2-seed-node2.lavanet.xyz:26656"
  PEERS=""
  sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.lava/config/config.toml

  sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.lava/config/app.toml
  sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.lava/config/app.toml
  sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.lava/config/app.toml
  sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.lava/config/app.toml

  sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.025ulava"|g' $HOME/.lava/config/app.toml
  sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.lava/config/config.toml

  sed -i \
    -e 's/timeout_commit = ".*"/timeout_commit = "30s"/g' \
    -e 's/timeout_propose = ".*"/timeout_propose = "1s"/g' \
    -e 's/timeout_precommit = ".*"/timeout_precommit = "1s"/g' \
    -e 's/timeout_precommit_delta = ".*"/timeout_precommit_delta = "500ms"/g' \
    -e 's/timeout_prevote = ".*"/timeout_prevote = "1s"/g' \
    -e 's/timeout_prevote_delta = ".*"/timeout_prevote_delta = "500ms"/g' \
    -e 's/timeout_propose_delta = ".*"/timeout_propose_delta = "500ms"/g' \
    -e 's/skip_timeout_commit = ".*"/skip_timeout_commit = false/g' \
    -e 's/seeds = ".*"/seeds = "3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@testnet2-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@testnet2-seed-node2.lavanet.xyz:26656"/g' \
    $HOME/.lava/config/config.toml

sed -i -e 's/broadcast-mode = ".*"/broadcast-mode = "sync"/g' $HOME/.lava/config/config.toml

sudo tee /etc/systemd/system/lavad.service > /dev/null << EOF
[Unit]
Description=Lava Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

lavad tendermint unsafe-reset-all --home $HOME/.lava --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
curl "https://snapshots-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"
  

printGreen "Запускаємо ноду"
sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u lavad -f -o cat"
printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
source $HOME/.bash_profile
printDelimiter
}

install
