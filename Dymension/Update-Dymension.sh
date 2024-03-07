#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function update() {
  clear
  source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
  printGreen "Оновлюємо Dymension"
  sudo systemctl stop dymd

  cd || return
  rm -rf dymension
  git clone https://github.com/dymensionxyz/dymension.git
  cd dymension || return
  git checkout v2.0.0-alpha.7
  make install

  sudo systemctl start dymd
  sudo journalctl -u dymd -f --no-hostname -o cat
  
  sleep 2
  printGreen "Версія вашої ноди:"
  dymd version
  echo ""
  
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u dymd -f -o cat"
  printGreen "Переглянути статус синхронізації: dymd status 2>&1 | jq .SyncInfo"
  printDelimiter
}

update