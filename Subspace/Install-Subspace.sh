#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

function install() {
printGreen "Розпочалось встановлення Gemini 3g v0.7.2"
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

sudo apt update && sudo apt install ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
cd $HOME
wget -O pulsar https://github.com/subspace/pulsar/releases/download/v0.7.1-alpha/pulsar-ubuntu-x86_64-skylake-v0.7.1-alpha
sudo chmod +x pulsar
sudo mv pulsar /usr/local/bin/
sudo rm -rf $HOME/.config/pulsar
/usr/local/bin/pulsar init
#systemctl stop subspaced subspaced-farmer &>/dev/null
#rm -rf ~/.local/share/subspace*

#source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pulsar farm --verbose
Restart=on-failure
LimitNOFILE=1024000

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service

sudo mv $HOME/subspaced.service /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced
sudo systemctl restart subspaced

if [[ `service subspaced status | grep active` =~ "running" ]]; then
echo ""
  echo "=================================================="
  printGreen "Subspace Gemini 3g v0.7.2 успішно встановлено"
  printGreen "Порти які використовує ваша нода:  30333,30433,30533"
  echo ""
  printGreen "Корисні команди:"
  echo "Перевірити статус ноди - systemctl status subspaced"
  echo "Журнал логів - journalctl -u subspaced -f -o cat"
  echo "=================================================="
  echo ""
else
  printGreen "Нода Subspace не встановлено, спробуйте встановити ще раз."
fi

touch $HOME/.sdd_Subspace_do_not_remove

}

install
touch $HOME/.sdd_Subspace_do_not_remove
