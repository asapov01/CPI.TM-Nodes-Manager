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

  printGreen "Moniker - назва вашого валідатора, яка буде використовуватись в подальшому"
  printGreen "Введіть moniker для вашої ноди(Наприклад:Asapov):"
  read -r NODE_MONIKER

  printGreen "Оновлення сервера та встановлення GO"
  sudo apt update
  sudo apt install -y curl git jq lz4 build-essential unzip

  bash <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source .bash_profile

  cd $HOME
  rm -rf dymension
  git clone https://github.com/dymensionxyz/dymension
  cd dymension
  git checkout v2.0.0-alpha.8

  make install

  dymd config chain-id froopyland_100-1
  dymd config keyring-backend test
  dymd init $NODE_MONIKER --chain-id froopyland_100-1

  curl -L https://snapshots-testnet.nodejumper.io/dymension-testnet/genesis.json > $HOME/.dymension/config/genesis.json
  curl -L https://snapshots-testnet.nodejumper.io/dymension-testnet/addrbook.json > $HOME/.dymension/config/addrbook.json

  sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@dymension-testnet.rpc.kjnodes.com:14659\"|" $HOME/.dymension/config/config.toml

  sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025udym,0.025uatom\"|" $HOME/.dymension/config/app.toml

  sed -i \
    -e 's|^pruning *=.*|pruning = "custom"|' \
    -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
    -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
    -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
    $HOME/.dymension/config/app.toml

  curl -L https://snapshots.kjnodes.com/dymension-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.dymension
  [[ -f $HOME/.dymension/data/upgrade-info.json ]] && cp $HOME/.dymension/data/upgrade-info.json $HOME/.dymension/cosmovisor/genesis/upgrade-info.json

  sudo systemctl daemon-reload
  sudo systemctl enable dymd.service

  sudo systemctl start dymd.service
  [ -e ~/.bash_profile ] || touch ~/.bash_profile
  source .bash_profile

  #Change port #8
  sed -i.bak -e "s%:1317%:2117%g; 
  s%:8080%:8880%g;
  s%:9090%:9890%g;
  s%:9091%:9891%g;
  s%:8545%:9345%g;
  s%:8546%:9346%g;
  s%:6065%:6865%g" $HOME/.dymension/config/app.toml	
  sed -i.bak -e "s%:26658%:34658%g;
  s%:26657%:34657%g;
  s%:6060%:6860%g;
  s%tcp://0.0.0.0:26656%tcp://0.0.0.0:34656%g;
  s%:26660%:34660%g" $HOME/.dymension/config/config.toml
  sed -i.bak -e "s%:26657%:34657%g" $HOME/.dymension/config/client.toml
  echo "" 

  sudo tee /etc/systemd/system/dymd.service > /dev/null <<EOF
[Unit]
Description=Dymension node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which dymd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable dymd.service
  source .bash_profile
  
  printGreen "Запускаємо ноду"
  sudo systemctl start dymd.service

  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u dymd -f -o cat"
  printGreen "Переглянути статус синхронізації: dymd status 2>&1 | jq .SyncInfo"
  echo -e "\e[1;32mВаша нода Dymension займає наступний набір портів(#8):\e[0m 2117,8880,6860,9890,9891,9345,9346,6865,34658,34660,34657,34656"
  printGreen "Запишіть значення портів, для можливості подальшого підселення космос нод, та уникнення конфліктів пов'язаних з портами"
  echo "alias port_dymension='echo -e \"\e[1;32mВаша нода Dymension займає наступний набір портів(#8):\e[0m 2017,8780,9790,9791,9245,9246,6765,33658,33657,6760,33656,33660\"'" >> ~/.bash_profile
  printGreen "Також якщо вам колись буде потрібно, введіть в терміналі port_dymension та ви знову побачите інформацію про список зайнятих портів"
  printDelimiter
  source ~/.bash_profile
}

install
