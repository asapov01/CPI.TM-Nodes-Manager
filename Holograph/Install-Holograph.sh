#!/bin/bash

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function holograph_faucet() {
  holograph faucet 
}

function install() {
  printGreen "Встановлення необхідних програмних компонентів..."
  echo ""

  sudo apt update && sudo apt upgrade -y
  sudo apt install curl -y
  sudo apt install git -y
  source ~/.bashrc && sleep 2
  sudo apt install screen

  echo ""
  printGreen "Встановлення Holograph..."
  printGreen "Ігноруйте подальші повідомлення npm WARN deprecated та run npm fund - це просто повідомлення про застарілу версію npm" && sleep 4
  echo ""
  npm install -g @holographxyz/cli
  echo ""
  printGreen "Оберіть мережі goerli, mumbai, fuji (Користуйтесь стрілками вниз-вверх, Space - для вибору мереж, ENTER - після вибору усіх 3 мереж."
  printGreen "Та перейдіть до гайду, для виконання наступних кроків по встановленню" 
  echo "" && sleep 3
  holograph config

  if [ $? -eq 0 ]; then
    for i in {1..3}; do
      holograph_faucet
    done
  fi
}

function done2() {
  printGreen "Запрошуємо у кожну мережу ще по 100 токенів HLG (Тричі натискайте Y , та запрошуйте у кожну мережу токени)"
  for i in {1..3}; do
    holograph_faucet
  done

  printGreen "Створюємо screen з назвою holograph - для стабільної та безперебійної роботи нашої ноди. Вийти з режиму screen - Ctrl + A + D"
  printGreen "В середині screen ви побачите застереження WARNING... просто вводите Y, вписуєте пароль та обираєте якусь з мереж та створюєте бондинг"
  printGreen "Поверніться до гайду, там буде більш детальна інструкція з поясненням" && sleep 10
 screen -S holograph bash -c 'sleep 2 && holograph operator:bond && printGreen "Нажимаємо Y - та створюємо бондинг у будь-якій з запропонованих мереж"'
}

clear
logo
printGreen "Перед початком встановлення вам потрібно виконати всі попередні кроки з гайду, а саме:"
echo ""
echo "1. Додати всі тестові мережі собі в Metamask"
echo "2. Запросити тестові токени на всі тестові мережі"
echo "3. Створити RPC в Alchemy"
echo ""
read -p "$(printGreen 'Якщо ви виконали всі умови, та вперше втановлюєте ноду, введіть 1. Якщо ви запросили вдруге 100 $HLG та маєте на балансі 200 $HLG у 3 мережах, введіть 2 [1/2]: ')" answer

if [ "$answer" = "1" ]; then
  printGreen "Розпочалось встановлення Holograph..."
  install
elif [ "$answer" = "2" ]; then
  done2
fi
