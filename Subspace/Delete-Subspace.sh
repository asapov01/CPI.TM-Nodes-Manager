#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop subspaced 
  sudo systemctl disable subspaced
  sudo rm -rf /root/.local/share/pulsar
  sudo rm -rf /etc/systemd/system/subspace*
  sudo rm -rf /usr/local/bin/subspace*
}

if [ -f $HOME/.sdd_Subspace_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "Subspace node видалено"
