#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

function update() {
printGreen "Розпочалось встановлення Subpsace Gemini 3g v0.7.2"
cd $HOME
wget -O pulsar https://github.com/subspace/pulsar/releases/download/v0.7.2-alpha/pulsar-ubuntu-x86_64-skylake-v0.7.2-alpha
sudo chmod +x pulsar
sudo mv pulsar /usr/local/bin/
sudo rm -rf $HOME/.config/pulsar
/usr/local/bin/pulsar init
sudo systemctl restart subspaced
sleep 1

if [[ `service subspaced status | grep active` =~ "running" ]]; then
echo ""
  echo "=================================================="
  printGreen "Subspace Gemini 3g v0.7.2 успішно встановлено"
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

printGreen "Під час встановлення ваша нода оновиться на актуальну мережу Gemini 3g v0.7.2. Ви згідні? (Y/N): "
read choice

if [[ "$choice" == "Y" || "$choice" == "y" ]]; then
  update
elif [[ "$choice" == "N" || "$choice" == "n" ]]; then
  printGreen "Ви відмовилися від перевстановлення ноди."
else
  printGreen "Невірний вибір. Будь ласка, введіть Y або N."
fi
