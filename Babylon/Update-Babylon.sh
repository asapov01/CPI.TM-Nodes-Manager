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
  printGreen "Наразі немає нових версій актуальних для оновлення."
  echo ""
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u babylond -f -o cat"
  printGreen "Переглянути статус синхронізації: babylond status 2>&1 | jq .SyncInfo"
  printDelimiter
}

update