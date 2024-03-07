#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  systemctl stop dymd && \
  systemctl disable dymd && \
  rm /etc/systemd/system/dymd.service && \
  systemctl daemon-reload && \
  cd $HOME && \
  rm -rf .dymension dymension && \
  rm -rf $(which dymd)
}

logo
delete

printGreen "Dymension node - видалено"