#!/bin/bash

# Password Hash
PASSWORD_HASH='$2a$12$BEwklxt0DeNBNP5DZeI7o.GA144WAAHhm.2pvq3OA9.DhVPEGjKNW'

if [ -z "$PASSWORD_HASH" ]; then
    echo "Error: PASSWORD_HASH is not set!"
    exit 1
fi

# Update the system and install the latest package versions
echo "Updating the system..."
sudo apt update -y > /dev/null 2>&1 && sudo apt upgrade -y > /dev/null 2>&1

# Install required packages
echo "Installing efivar..."
sudo apt install -y efivar > /dev/null 2>&1

echo "Installing OpenVPN..."
sudo apt install -y openvpn > /dev/null 2>&1

echo "Installing OpenVPN DKMS..."
sudo apt install -y openvpn-dco-dkms > /dev/null 2>&1

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1
sudo sh get-docker.sh > /dev/null 2>&1
rm get-docker.sh

# Clone the antizapret-vpn-docker repository
echo "Cloning the antizapret-vpn-docker repository..."
sudo git clone https://github.com/xtrime-ru/antizapret-vpn-docker.git /root/antizapret > /dev/null 2>&1

# Navigate to the antizapret directory
cd /root/antizapret

# Create the docker-compose.override.yml file with the necessary content
echo "Creating docker-compose.override.yml..."
cat <<EOL > /root/antizapret/docker-compose.override.yml
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
      - OPENVPN_MTU=1420
    ports:
      - "6841:1194/tcp"
      - "6841:1194/udp"
  amnezia-wg-easy:
    environment:
      - PASSWORD_HASH=${PASSWORD_HASH}
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

# Create an empty wireguard.env file
echo "Creating an empty wireguard.env file..."
sudo touch antizapret/wireguard/wireguard.env

# Perform docker compose pull
echo "Pulling Docker images..."
sudo docker compose pull > /dev/null 2>&1

# Start the containers
echo "Starting containers..."
sudo docker compose up -d > /dev/null 2>&1

# Download and replace configuration files
echo "Downloading configuration files..."

echo "Downloading include-hosts-custom.txt..."
curl -fsSL "http://omhvp.co/include-hosts-custom.txt" \
     -o /root/antizapret/config/include-hosts-custom.txt > /dev/null 2>&1

echo "Downloading include-ips-custom.txt..."
curl -fsSL "http://omhvp.co/include-ips-custom.txt" \
     -o /root/antizapret/config/include-ips-custom.txt > /dev/null 2>&1

echo "Downloading include-regex-custom.txt..."
curl -fsSL "http://omhvp.co/include-regex-custom.txt" \
     -o /root/antizapret/config/include-regex-custom.txt > /dev/null 2>&1

# Restart the containers
echo "Restarting containers..."
sudo docker compose restart > /dev/null 2>&1

# Display the OpenVPN client configuration
echo "Displaying the OpenVPN client configuration file..."
cat ~/antizapret/keys/client/antizapret-client-udp.ovpn

# Schedule a reboot in 1 minute
echo "Scheduling a reboot in 1 minute..."
sudo shutdown -r +1

# Final message
echo "All done. The system is ready! Reboot scheduled in 1 minute."
