#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop meson_cdn
  rm -rf meson_cdn-linux-amd64
}

if [ -f $HOME/.sdd_Meson_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "Meson node видалено"
