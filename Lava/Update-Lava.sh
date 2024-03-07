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
  printGreen "Оновлюємо Lava"
  echo ""
  sudo systemctl stop lavad

  cd $HOME
  wget -O lavad https://github.com/lavanet/lava/releases/download/v0.33.0/lavad-v0.33.0-linux-amd64
  chmod +x $HOME/lavad
  sudo mv $HOME/lavad $(which lavad)
  sudo systemctl start lavad
  sleep 2
  printGreen "Версія вашої ноди:"
  lavad version
  echo ""
  
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u lavad -f -o cat"
  printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo"
  printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
  printDelimiter
}

install
