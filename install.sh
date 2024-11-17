#!/bin/bash

# Обновляем систему и устанавливаем последние версии пакетов
echo "Обновляем систему..."
sudo apt update -y && sudo apt upgrade -y

# Устанавливаем необходимые пакеты
echo "Устанавливаем efivar..."
sudo apt install -y efivar

echo "Устанавливаем OpenVPN..."
sudo apt install -y openvpn

echo "Устанавливаем OpenVPN DKMS..."
sudo apt install -y openvpn-dco-dkms

# Устанавливаем Docker
echo "Устанавливаем Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Клонируем репозиторий antizapret-vpn-docker
echo "Клонируем репозиторий antizapret-vpn-docker..."
git clone https://github.com/xtrime-ru/antizapret-vpn-docker.git antizapret

# Переходим в директорию antizapret
cd antizapret

# Создаём файл docker-compose.override.yml с необходимым содержимым
echo "Создаём файл docker-compose.override.yml..."
cat <<EOL > docker-compose.override.yml
services:
  antizapret-vpn:
    environment:
      - DNS
      - ADGUARD=0
      - OPENVPN_OPTIMIZATIONS=1
      - OPENVPN_TLS_CRYPT=1
      - LOG_DNS=0
      - SKIP_UPDATE_FROM_ZAPRET=false
      - UPDATE_TIMER=1d
      - OPENVPN_PORT=6841
      - OPENVPN_HOST=me.omhvp.co
      - OPENVPN_MTU=1420
    ports:
      - "6841:1194/tcp"
      - "6841:1194/udp"
  amnezia-wg-easy:
    environment:
      - PASSWORD_HASH=\$\$2a\$12\$\$BEwklxt0DeNBNP5DZeI7o.GA144WAAHhm.2pvq3OA9.DhVPEGjKNW
      - WG_ALLOWED_IPS=10.224.0.0/15,10.1.166.0/24,103.246.200.0/22,178.239.88.0/21,185.104.45.0/24,193.105.213.36/30,203.104.128.0/20,203.104.144.0/21,203.104.152.0/22,68.171.224.0/19,74.82.64.0/19,104.109.143.0/24,66.22.192.0/18,35.192.0.0/11,34.0.192.0/18
      - WG_DEFAULT_DNS=10.224.0.1
      - WG_PERSISTENT_KEEPALIVE=10
      - FORCE_FORWARD_DNS=true
      - LANGUAGE=ru
      - PORT=1481
      - UI_TRAFFIC_STATS=true
      - UI_CHART_TYPE=2
      - WG_PORT=1480
      - WG_ENABLE_EXPIRES_TIME=true
      - WG_ENABLE_ONE_TIME_LINKS=true
      - UI_ENABLE_SORT_CLIENTS=false
    ports:
      - "1480:1480/udp"
      - "1481:1481/tcp"
    extends:
      file: docker-compose.wireguard-amnezia.yml
      service: amnezia-wg-easy
EOL

# Выполняем docker compose pull
echo "Выполняем docker compose pull..."
sudo docker compose pull

# Запускаем контейнеры в фоне
echo "Запускаем контейнеры..."
sudo docker compose up -d

# Меняем содержимое файлов в папке antizapret
echo "Изменяем файлы конфигурации..."

# Пример, как изменить файлы, указываю на замену:
echo "Изменение include-hosts-custom.txt..."
cat <<EOL > antizapret/config/include-hosts-custom.txt
# Пример содержимого
example.com
another-example.com
EOL

echo "Изменение include-ips-custom.txt..."
cat <<EOL > antizapret/config/iinclude-ips-custom.txt
# Пример содержимого
192.168.1.1
10.0.0.1
EOL

echo "Изменение include-regex-custom.txt..."
cat <<EOL > antizapret/config/include-regex-custom.txt
# Пример содержимого
^.*\.example\.com$
EOL

# Перезапускаем контейнеры
echo "Перезапускаем контейнеры..."
sudo docker compose restart

# Выводим путь к файлу .ovpn
echo "Выводим файл .ovpn..."
cat antizapret/keys/client/antizapret-client-udp.ovpn

echo "Установка и настройка завершены."
