#!/bin/bash

# Функция для отображения логотипа
display_logo() {
  echo -e '\033[32m'
  echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
  echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
  echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
  echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
  echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
  echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
  echo -e '\033[32m'

  echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"
}

# Функция для установки ноды Waku
install_waku_node() {
  read -p "Введите Вашу RPC ссылку (ETH Sepolia Network): " rpc_link
  read -p "Введите Private Key от кошелька с Ethereum Sepolia. Убедитесь, что на балансе есть больше 0.1 ETH Sepolia: " private_key
  read -p "Создайте пароль: " password
  echo

  sudo apt update && sudo apt upgrade -y
  sudo apt-get install build-essential git libpq5 jq -y
  yes "" | curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env"
  rustc --version
  sudo apt install docker.io -y
  docker --version
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version
  git clone https://github.com/waku-org/nwaku-compose
  cd nwaku-compose
  cp .env.example .env

  sed -i "s|RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$rpc_link|" .env
  sed -i "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$private_key|" .env
  sed -i "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=\"$password\"|" .env

  git pull origin master
  ./register_rln.sh
  sudo ufw enable
  sudo ufw allow 22
  sudo ufw allow 3000
  sudo ufw allow 8545
  sudo ufw allow 8645
  sudo ufw allow 9005
  sudo ufw allow 30304
  docker-compose up -d

  server_ip=$(hostname -I | awk '{print $1}')
  echo "Установка ноды Waku завершена! Вы можете следить за состоянием своей ноды через Grafana по адресу: http://$server_ip:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1&refresh=1m . Также, Вы можете отследить запросы ноды в своем личном кабинете Alchemy."
  main_menu
}

# Функция для проверки состояния ноды Waku
check_waku_node_status() {
  curl -X GET http://localhost:8645/health
  main_menu
}

# Главное меню
main_menu() {
  display_logo

  echo "Меню:"
  echo "1. Установить ноду Waku"
  echo "2. Проверить состояние ноды Waku"
  echo "3. Выйти из скрипта"

  read -p "Выберите опцию: " option

  case $option in
    1)
      install_waku_node
      ;;
    2)
      check_waku_node_status
      ;;
    3)
      echo "Выход из скрипта..."
      exit 0
      ;;
    *)
      echo "Неверная опция, попробуйте снова."
      main_menu
      ;;
  esac
}

# Запуск главного меню
main_menu
