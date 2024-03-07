#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
clear
logo
printGreen "Видаляємо Holograph..." && sleep 2
 npm uninstall -g @holographxyz/cli
 sudo rm -r /usr/local/lib/node_modules/@holographxyz
 rm -rf /root/.config/holograph
printGreen "Видаляємо screen holograph"
 screen -S holograph -X quit
}

delete

printGreen "Holograph node видалено"