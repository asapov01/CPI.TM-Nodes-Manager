#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop zetacored
  sudo systemctl disable zetacored
  sudo rm -rf $HOME/.zetacored
  sudo rm -rf $HOME/zetacored
  sudo rm -rf $HOME/zetacored
  sudo rm -rf /etc/systemd/system/zetacored.service
  sudo rm -rf /usr/local/bin/zetacored
  sudo systemctl daemon-reload
}



logo
delete

printGreen "Zetachain node видалено"
