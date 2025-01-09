#!/bin/bash
set -e
set -x

# Function for error handling
handle_error() {
    echo "An error occurred on line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Save original directory
ORIGINAL_DIR=$(pwd)

# Verify/Install Git
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
fi

# Update system and install OpenSSL
sudo apt-get update
sudo apt-get install -y libssl-dev xutils-dev

# Setup FTP
mkdir -p /home/$USER/FTP/files
chmod a-w /home/$USER/FTP
sudo apt-get install -y vsftpd

# Copy the prepared vsftpd configuration
sudo cp /home/MWPEnv/misc/vsftpd.conf /etc/.

# Restart FTP service
sudo service vsftpd restart

# Verify FTP service is running
if ! systemctl is-active --quiet vsftpd; then
    echo "Error: vsftpd failed to start"
    sudo journalctl -u vsftpd -n 50
    exit 1
fi

# Install required libraries
sudo apt-get install -y libjson-c-dev cmake mosquitto mosquitto-clients

# Configure and restart Mosquitto
sudo systemctl stop mosquitto
sudo systemctl enable mosquitto.service

# Backup and update Mosquitto configuration
if [ -f /etc/mosquitto/mosquitto.conf ]; then
    sudo cp /etc/mosquitto/mosquitto.conf /etc/mosquitto/mosquitto.conf.backup
fi

# Create fresh mosquitto.conf
echo "listener 1883
allow_anonymous true
persistence true
persistence_location /var/lib/mosquitto/
log_dest file /var/log/mosquitto/mosquitto.log" | sudo tee /etc/mosquitto/mosquitto.conf

# Start Mosquitto service
sudo systemctl start mosquitto

# Verify Mosquitto is running
if ! systemctl is-active --quiet mosquitto; then
    echo "Error: Mosquitto failed to start"
    sudo journalctl -u mosquitto -n 50
    exit 1
fi

# Install MQTT
git clone https://github.com/eclipse/paho.mqtt.c.git
cd paho.mqtt.c || exit 1
make
sudo make install
cd "$ORIGINAL_DIR" || exit 1

# Configure Mosquitto
if [ -f /etc/mosquitto/mosquitto.conf ]; then
    sudo cp /etc/mosquitto/mosquitto.conf /etc/mosquitto/mosquitto.conf.backup
fi

echo "listener 1883
allow_anonymous true" | sudo tee -a /etc/mosquitto/mosquitto.conf

# Install Python dependencies
pip install --upgrade pip
git clone https://github.com/allenporter/pyrainbird.git
cd pyrainbird || exit 1
pip install -r requirements_dev.txt --ignore-requires-python
pip install . --ignore-requires-python
pip install paho-mqtt
cd "$ORIGINAL_DIR" || exit 1

# Create project directories
mkdir -p MWPLogData

# Verify services
verify_service vsftpd
verify_service mosquitto

echo "Setup script has completed successfully."