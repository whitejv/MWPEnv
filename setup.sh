#!/bin/bash
set -x

# Install OpenSSL for C/C++ programs
sudo apt-get update
sudo apt-get install -y libssl-dev xutils-dev

# Install FTP Daemon and configure it
mkdir -p /home/$USER/FTP/files
chmod a-w /home/$USER/FTP
sudo apt-get install -y vsftpd
sudo service vsftpd restart

# Install JSON Lib, CMake, Mosquitto MQTT Service
sudo apt-get install -y libjson-c-dev 
sudo apt-get install -y cmake 
sudo apt-get install -y mosquitto mosquitto-clients

# Enable Mosquitto service and check its version
sudo systemctl enable mosquitto.service
mosquitto -v

# Install MQTT and update its config and application libraries
git clone https://github.com/eclipse/paho.mqtt.c.git
cd paho.mqtt.c
make
sudo make install
cd /etc/mosquitto
echo "listener 1883
allow_anonymous true" | sudo tee -a mosquitto.conf

echo "Setup script has finished executing."
