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
  printGreen "Оновлюємо Zetachain"
  echo ""
  sudo systemctl stop zetacored

  mkdir -p $HOME/go/bin
  curl -L https://github.com/zeta-chain/node/releases/download/v12.0.0-rc/zetacored-linux-amd64 > $HOME/go/bin/zetacored
  chmod +x $HOME/go/bin/zetacored
  sudo systemctl start zetacored
  sleep 2
  printGreen "Версія вашої ноди:"
  zetacored version
  echo ""
  
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u zetacored -f -o cat"
  printGreen "Переглянути статус синхронізації: zetacored status 2>&1 | jq .SyncInfo"
  printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
  printDelimiter
}

install
