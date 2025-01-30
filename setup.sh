#!/bin/bash
set -e
set -x

#Define all functions at the start
handle_error() {
    echo "An error occurred on line $1"
    exit 1
}

verify_service() {
    if ! systemctl is-active --quiet $1; then
        echo "Error: $1 failed to start"
        exit 1
    fi
}

#Set error handling
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
mkdir -p "/home/pi/FTP/files"  # Changed to use absolute path
chmod a-w "/home/pi/FTP"
sudo apt-get install -y vsftpd

# Copy the prepared vsftpd configuration
sudo cp /home/pi/MWPEnv/misc/vsftpd.conf /etc/.

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

# Copy the prepared mosquitto configuration
sudo cp /home/pi/MWPEnv/misc/mymosquitto.conf /etc/mosquitto/conf.d/.

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

# Create project directories
mkdir -p MWPLogData
# Ensure correct ownership and permissions
chown pi:pi MWPLogData
chmod 777 MWPLogData

# Also ensure FTP directories have correct ownership
chown pi:pi "/home/pi/FTP"
chown pi:pi "/home/pi/FTP/files"
chmod 755 "/home/pi/FTP/files"

# Verify services
verify_service vsftpd
verify_service mosquitto

echo "Basic system setup completed successfully. Run setupPy.sh to set up Python environment."
