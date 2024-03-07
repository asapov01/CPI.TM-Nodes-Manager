#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\033[1;32m${1}\033[0m"
}

function printDelimiter {
  echo "==========================================="
}

clear
logo

function install() {
    printGreen "Розпочався процес встановлення..." && sleep 2

    printGreen "Встановлюємо Docker"
    sudo apt install wget jq ca-certificates gnupg -y
    source /etc/*-release
    rm -f /usr/share/keyrings/docker-archive-keyring.gpg
    wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io apparmor -y

    printGreen "Встановлюємо Docker Compose"
    docker_compose_version=$(wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name")
    sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)"
    sudo chmod +x /usr/bin/docker-compose
    docker-compose -v

    printGreen "Встановлюємо ноду"
    curl -O https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh && chmod +x installer.sh && ./installer.sh

    status_output=$(docker exec -it shardeum-dashboard operator-cli status) && sleep 3
    if [[ $status_output == *"state: standby"* ]] || [[ $status_output == *"state: stopped"* ]]; then
        printDelimiter
        printGreen "Нода встановлена успішно"
        printGreen "Відкрийте свій браузер, перейдіть до Дашборду, запустіть ноду та зробіть стейкінг токенів"
        printGreen "Порт який використовує нода: 8080"
        printDelimiter
    else
        printGreen "Помилка при встановленні ноди, спочатку видаліть її та встановіть ще раз."
    fi
}

install
