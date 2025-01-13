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

install_rust() {
    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        # Download and install Rust
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # Add Rust to current shell PATH
        source "$HOME/.cargo/env"
        # Verify installation
        if ! command -v rustc &> /dev/null; then
            echo "Rust installation failed"
            exit 1
        fi
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
mkdir -p /home/pi/$USER/FTP/files
chmod a-w /home/pi/$USER/FTP
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

# Install Rust (required for some Python packages)
install_rust

# Install Python virtual environment package
sudo apt-get install -y python3-venv python3-full

# Create virtual environment
python3 -m venv ~/mwp_venv

# Activate virtual environment
source ~/mwp_venv/bin/activate

# Install Python dependencies within virtual environment
pip install --upgrade pip

# Ensure Rust is in PATH for the virtual environment
source "$HOME/.cargo/env"

git clone https://github.com/allenporter/pyrainbird.git
cd pyrainbird || exit 1
pip install -r requirements_dev.txt --ignore-requires-python
pip install . --ignore-requires-python
pip install paho-mqtt
cd "$ORIGINAL_DIR" || exit 1

# Deactivate virtual environment
deactivate

# Create activation script for future use
echo '#!/bin/bash
source ~/mwp_venv/bin/activate' > activate_mwp.sh
chmod +x activate_mwp.sh

# Create project directories
mkdir -p MWPLogData

# Verify services
verify_service vsftpd
verify_service mosquitto

echo "Setup script has completed successfully."
