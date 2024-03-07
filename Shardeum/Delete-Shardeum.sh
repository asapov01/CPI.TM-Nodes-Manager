#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  docker stop shardeum-dashboard && docker rm shardeum-dashboard
  rm -rf .shardeum/
}

if [ -f $HOME/.sdd_Shardeum_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "Shardeum node видалено"
