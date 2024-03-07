#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  systemctl stop nibid
  systemctl disable nibid
  rm -rf $(which nibid) ~/.nibid ~/nibiru
}

if [ -f $HOME/.sdd_Nibiru_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "Nibiru node видалено"
