#!/bin/bash

function uninstall() {
	sudo systemctl stop docker.service docker.socket
	sudo systemctl disable docker.service docker.socket
	sudo rm -rf `systemctl cat docker.service | grep -oPm1 "(?<=^#)([^%]+)"` `systemctl cat docker.socket | grep -oPm1 "(?<=^#)([^%]+)"` /usr/bin/docker-compose
	sudo apt purge docker-engine docker docker.io docker-ce docker-ce-cli -y
	sudo apt autoremove --purge docker-engine docker docker.io docker-ce -y
	sudo apt autoclean
	sudo rm -rf /var/lib/docker /etc/appasudo rmor.d/docker
	sudo groupdel docker
	sudo rm -rf /etc/docker /usr/bin/docker /usr/libexec/docker /usr/libexec/docker/cli-plugins/docker-buildx /usr/libexec/docker/cli-plugins/docker-scan /usr/libexec/docker/cli-plugins/docker-app /usr/share/keyrings/docker-archive-keyring.gpg
}

uninstall
