#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {
    sudo apt --fix-broken install
    sudo apt-get update && sudo apt-get upgrade -y
    sudo dpkg --configure -a
    sudo apt-get install -f -y
    sudo apt install tar curl git ufw -y

    sudo ufw disable
    sudo ufw allow 443
    wget 'https://staticassets.meson.network/public/meson_cdn/v3.1.20/meson_cdn-linux-amd64.tar.gz' && tar -zxf meson_cdn-linux-amd64.tar.gz && rm -f meson_cdn-linux-amd64.tar.gz && cd ./meson_cdn-linux-amd64 && sudo ./service install meson_cdn
    
    if [[ -z "$tokencommand" ]]; then
        read -p "Please insert set token and config command from website: " _tokencommand
        export tokencommand=$_tokencommand
    fi

    
    sudo ./meson_cdn config set --token=$tokencommand --https_port=443 --cache.size=30
    cd

    MESON=meson_cdn-linux-amd64
    echo 'export MESON=meson_cdn-linux-amd64' >> ~/.bash_profile
    source ~/.bash_profile
    sudo $MESON/service start meson_cdn
    sudo $MESON/service status meson_cdn
}


if [ ! -f $HOME/.sdd_Meson_do_not_remove ]; then
  logo
fi

printDelimiter
printGreen "Переглянути роботу вашої ноди ви можете в дашборді, який створювали в розділі Daily Reward"
printGreen "Порти які використовує ваша нода: 443"
printDelimiter

install
touch $HOME/.sdd_Meson_do_not_remove
