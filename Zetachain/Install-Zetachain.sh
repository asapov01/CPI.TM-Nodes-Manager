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

  CHAIN_ID="athens_7001-1"
  CHAIN_DENOM="azeta"
  BINARY_NAME="zetacored"
  BINARY_VERSION_TAG="v12.0.0-rc"
  printGreen "Встановлення необхідних залежностей"
  sudo apt update
  sudo apt install -y curl git jq lz4 build-essential unzip
  bash <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source .bash_profile

  
  printGreen "Встановлення Zetachain"
  mkdir -p $HOME/go/bin
  curl -L https://github.com/zeta-chain/node/releases/download/v12.0.0-rc/zetacored-linux-amd64 > $HOME/go/bin/zetacored
  chmod +x $HOME/go/bin/zetacored

  zetacored config chain-id $CHAIN_ID
  zetacored config keyring-backend test
  zetacored init "$NODE_MONIKER" --chain-id $CHAIN_ID

  curl -L https://raw.githubusercontent.com/zeta-chain/network-athens3/main/network_files/config/genesis.json > $HOME/.zetacored/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/zetachain-testnet/addrbook.json > $HOME/.zetacored/config/addrbook.json

SEEDS="3f472746f46493309650e5a033076689996c8881@zetachain-testnet.rpc.kjnodes.com:16059"
PEERS=""
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.zetacored/config/config.toml

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.zetacored/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.zetacored/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.zetacored/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.zetacored/config/app.toml
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0001azeta"|g' $HOME/.zetacored/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.zetacored/config/config.toml

sudo tee /etc/systemd/system/zetacored.service > /dev/null << EOF
[Unit]
Description=ZetaChain Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which zetacored) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
WorkingDirectory=$HOME
[Install]
WantedBy=multi-user.target
EOF

zetacored tendermint unsafe-reset-all --home $HOME/.zetacored --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots-testnet.nodejumper.io/zetachain-testnet/info.json | jq -r .fileName)
curl "https://snapshots-testnet.nodejumper.io/zetachain-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.zetacored"

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:29658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:29657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6360\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:29656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":29660\"%" $HOME/.zetacored/config/config.toml && sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9390\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9391\"%; s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1617\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:8845\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:8846\"%; s%^address = \"127.0.0.1:8545\"%address = \"127.0.0.1:8845\"%; s%^ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:8846\"%" $HOME/.zetacored/config/app.toml && sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:29657\"%" $HOME/.zetacored/config/client.toml 
printGreen "Запускаємо ноду"
sudo systemctl daemon-reload
sudo systemctl enable zetacored
sudo systemctl start zetacored
source $HOME/.bash_profile

  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u zetacored -f -o cat"
  printGreen "Переглянути статус синхронізації: zetacored status 2>&1 | jq .SyncInfo"
  printGreen "Версія вашої ноди:"
  zetacored version
  printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
  printDelimiter
}

install
