#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

function update() {
  printGreen "Перед оновленням зайдіть до свого Дашборду зробіть анстейк токенів та зупиніть ноду."
  printGreen "Якщо ви виконали ці дії,бажаєте оновити? (Y/N)"
  read response

  if [[ $response == "Y" || $response == "y" ]]; then
    printGreen "Оновлюємо..."
    sudo apt update
    cd ..
    curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && ./installer.sh
    printGreen "Оновлення завершено, перейдіть до Дашборду зробіть стейкінг токенів та запустіть вашу ноду"
  else
    echo "Оновлення не виконано."
  fi
}

update
