#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printDelimiter {
  echo "==========================================="
}

function remove_node() {
    printDelimiter
    printGreen "Видаляємо застарілу версію Nibiru" && sleep 3
    printDelimiter
    systemctl stop nibid
    systemctl disable nibid
    rm -rf $(which nibid) ~/.nibid ~/nibiru
    printDelimiter
    printGreen "Через декілька секунд, розпочнеться звичайний процес встановлення ноди" && sleep 3
    printDelimiter
}

function install() {
clear
logo

printGreen "Введіть ім'я для вашої ноди:"
read -r NODE_MONIKER

CHAIN_ID="nibiru-itn-3"
CHAIN_DENOM="unibi"
BINARY_NAME="nibid"
BINARY_VERSION_TAG="v0.21.11"

source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Nibiru/Dependencies.sh)

echo ""
printGreen "Встановлюємо бінарні файли ноди"

cd $HOME || return
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru
cd $HOME/nibiru || return
git checkout $BINARY_VERSION_TAG
make install
nibid version # 0.21.11

nibid config keyring-backend os
nibid config chain-id $CHAIN_ID
nibid init "$NODE_MONIKER" --chain-id $CHAIN_ID

curl -s https://snapshots-testnet.stake-town.com/nibiru/genesis.json > $HOME/.nibid/config/genesis.json
curl -s https://snapshots-testnet.stake-town.com/nibiru/addrbook.json > $HOME/.nibid/config/addrbook.json

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:30658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:30657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:30656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":30660\"%" $HOME/.nibid/config/config.toml && sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9490\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9491\"%; s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1717\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:8945\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:8946\"%; s%^address = \"127.0.0.1:8545\"%address = \"127.0.0.1:8945\"%; s%^ws-address = \"127.0.0.1:8546\"%ws-address = \"127.0.0.1:8946\"%" $HOME/.nibid/config/app.toml && sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:30657\"%" $HOME/.nibid/config/client.toml 
sudo sed -i.bak -e 's/^address = "localhost:9090"/address = "localhost:9690"/' -e 's/^address = "localhost:9091"/address = "localhost:9691"/' /root/.nibid/config/app.toml

printGreen "Встановлюємо Cosmovisor" && sleep 1

go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
mkdir -p ~/.nibid/cosmovisor/genesis/bin
mkdir -p ~/.nibid/cosmovisor/upgrades
cp ~/go/bin/nibid $HOME/.nibid/cosmovisor/genesis/bin

printGreen "Завантажуємо снепшот для прискорення синхронізації ноди..." && sleep 1

sudo tee /etc/systemd/system/nibid.service > /dev/null << EOF
[Unit]
Description=Nibiru Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
Environment="DAEMON_NAME=nibid"
Environment="DAEMON_HOME=$HOME/.nibid"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF

nibid tendermint unsafe-reset-all --home $HOME/.nibid --keep-addr-book


URL="https://snapshots-testnet.stake-town.com/nibiru/nibiru-itn-3_latest.tar.lz4"
curl $URL | lz4 -dc - | tar -xf - -C $HOME/.nibid
[[ -f $HOME/.nibid/data/upgrade-info.json ]]  && cp $HOME/.nibid/data/upgrade-info.json $HOME/.nibid/cosmovisor/genesis/upgrade-info.json

sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl start nibid

source ~/.bashrc
source ~/.bash_profile


printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u nibid -f -o cat"
printGreen "Переглянути статус синхронізації: nibid status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 30658,30657,6460,30656,30660,9490,9491,30657,9690,9691"
printGreen "В журналі логів спочатку ви можете побачити INF Ensure peers=. Але за 5-15 секунд нода розпочне синхронізацію"
printDelimiter

}

function backup_files() {
    source_dir="/root/.nibid/"
    backup_dir="/root/BACKUPNODES/Nibiru backup"
    files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
    printGreen "Копіюємо файли ноди Nibiru в папку резервних копій" && sleep 3
    mkdir -p "$backup_dir"
    for file_to_copy in "${files_to_copy[@]}"; do
        if [ -f "$source_dir/$file_to_copy" ]; then
            cp "$source_dir/$file_to_copy" "$backup_dir/" || { printRed "Не вдалось скопіювати файли ноди Nibiru"; return; }
        fi
    done
    echo "Збережено файли ноди Nibiru" && sleep 3
}

remove_node
install
backup_files
