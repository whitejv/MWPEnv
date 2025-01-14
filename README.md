# MWP Environment Setup Guide

This guide provides instructions for setting up the Raspberry Pi Linux environment for the Milano Water Project (MWP). It covers initial Pi configuration, package updates, and installation of required services including SSH, FTP, JSON, and MQTT.

## Prerequisites

- Raspberry Pi 4/5 with fresh OS installation
- Monitor, keyboard, and mouse (for initial setup only)
- Network connection
- Basic familiarity with Linux commands
- User account must be 'pi' (default Raspberry Pi user)

## Initial Setup

### 1. Enable Remote Access

Initial setup requires physical access to the Raspberry Pi. After this step, all remaining configuration can be done remotely.

On the Raspberry Pi:
1. Click the Raspberry Pi logo → Preferences → Raspberry Pi Configuration
2. Navigate to Interface Tab
3. Enable VNC

On your Mac:
```bash
ssh pi@xxx.local  # Replace xxx with your Pi's hostname
# Default password: raspberry
sudo raspi-config  # Navigate to Interfaces and enable VNC
```

### 2. Update System Packages

```bash
sudo apt update
sudo apt full-upgrade
sudo reboot
```

## Automated Installation (Recommended)

The fastest way to set up your environment is using our automated setup scripts:

```bash
# Clone the repository
git clone https://github.com/whitejv/MWPEnv.git

# Copy and make the setup scripts executable
cp MWPEnv/setup.sh MWPEnv/setupPy.sh MWPEnv/cleanPy.sh .
chmod +x setup.sh setupPy.sh cleanPy.sh

# Run the setup scripts in sequence
./setup.sh    # Will prompt for sudo password when needed
./setupPy.sh  # Will prompt for sudo password only for initial package installation
```

The scripts will automatically:
- `setup.sh`:
  - Install and configure all required system packages (requires sudo)
  - Set up FTP server using prepared configuration
  - Configure MQTT using prepared configuration
  - Create necessary project directories with proper ownership
  - Verify all service installations

- `setupPy.sh`:
  - Install Rust (required for some Python packages)
  - Install Python virtual environment package (requires sudo briefly)
  - Create and configure a Python virtual environment
  - Install all required Python dependencies
  - Create activation script for the virtual environment
  - Ensure all files and directories have correct ownership

If you encounter issues with Python setup, you can use the cleanup script:
```bash
./cleanPy.sh  # Removes Python environment for fresh installation
./setupPy.sh  # Run Python setup again
```

### After Installation

1. The script creates a Python virtual environment. To activate it:
```bash
source ~/mwp_venv/bin/activate  # Or use ./activate_mwp.sh
```

2. When finished working with Python packages:
```bash
deactivate
```

3. Verify services are running:
```bash
systemctl status vsftpd
systemctl status mosquitto
```

## Manual Installation Steps (Alternative Method)

If you prefer to install components individually or need to troubleshoot the automated installation, follow these steps:

### 1. Install Git and Initial Packages
```bash
sudo apt update
sudo apt-get install -y git
sudo apt-get install -y libssl-dev xutils-dev
```

### 2. Setup FTP Server
```bash
# Create FTP directories
mkdir -p "/home/pi/FTP/files"
chmod a-w "/home/pi/FTP"

# Install FTP server
sudo apt-get install -y vsftpd

# Copy configuration file
sudo cp /home/pi/MWPEnv/misc/vsftpd.conf /etc/.
sudo service vsftpd restart

# Verify service
systemctl status vsftpd
```

### 3. Install Development Libraries
```bash
sudo apt-get install -y libjson-c-dev cmake
```

### 4. Setup MQTT (Mosquitto)
```bash
# Install Mosquitto
sudo apt-get install -y mosquitto mosquitto-clients

# Stop service for configuration
sudo systemctl stop mosquitto
sudo systemctl enable mosquitto.service

# Copy configuration file
sudo cp /home/pi/MWPEnv/misc/mymosquitto.conf /etc/mosquitto/conf.d/.

# Start service
sudo systemctl start mosquitto

# Verify service
systemctl status mosquitto
```

### 5. Install MQTT Client Library
```bash
git clone https://github.com/eclipse/paho.mqtt.c.git
cd paho.mqtt.c
make
sudo make install
cd ..
```

### 6. Install Rust (Required for Python Packages)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```

### 7. Setup Python Environment
```bash
# Install Python requirements (requires sudo)
sudo apt-get install -y python3-venv python3-full

# Create and activate virtual environment
python3 -m venv ~/mwp_venv
source ~/mwp_venv/bin/activate

# Ensure virtual environment has correct ownership
chown -R pi:pi ~/mwp_venv

# Ensure Rust is in PATH
source "$HOME/.cargo/env"

# Install Python packages
pip install --upgrade pip
git clone https://github.com/allenporter/pyrainbird.git
cd pyrainbird
pip install --no-dependencies -r requirements_dev.txt --ignore-requires-python
pip install . --ignore-requires-python
pip install paho-mqtt
cd ..

# Create activation script
echo '#!/bin/bash
source ~/mwp_venv/bin/activate' > activate_mwp.sh
chmod +x activate_mwp.sh
chown pi:pi activate_mwp.sh

# Deactivate virtual environment
deactivate
```

### 8. Create Project Directories
```bash
mkdir -p MWPLogData
chown pi:pi MWPLogData
chmod 755 MWPLogData
```

### 9. Verify Installation
```bash
# Check service status
systemctl status vsftpd
systemctl status mosquitto

# Test virtual environment
source ~/mwp_venv/bin/activate
python -c "import paho.mqtt.client as mqtt; print('MQTT client available')"
deactivate
```

## Service Locations

Key files and directories:
- FTP root: `/home/pi/FTP/files`
- MQTT config: `/etc/mosquitto/conf.d/mymosquitto.conf`
- vsftpd config: `/etc/vsftpd.conf`
- Python virtual environment: `~/mwp_venv`
- Log directory: `MWPLogData`

## Troubleshooting

If you encounter issues with the automated scripts:

1. Check requirements:
   - Ensure you're running as the 'pi' user
   - Verify you have internet connectivity
   - Ensure all prerequisites are installed

2. Common issues:
   - If services fail to start, check logs:
     ```bash
     sudo journalctl -u vsftpd -n 50
     sudo journalctl -u mosquitto -n 50
     ```
   - If Python setup fails:
     ```bash
     ./cleanPy.sh  # Clean up Python environment
     ./setupPy.sh  # Try Python setup again
     ```
   - If Python packages fail to install, ensure you're in the virtual environment:
     ```bash
     source ~/mwp_venv/bin/activate
     ```
   - If you have permission issues:
     ```bash
     # Fix ownership of virtual environment
     sudo chown -R pi:pi ~/mwp_venv
     # Fix ownership of project directories
     sudo chown -R pi:pi MWPLogData
     ```

3. Manual verification:
   - FTP service: `systemctl status vsftpd`
   - MQTT service: `systemctl status mosquitto`
   - Python virtual environment: `which python` should point to ~/mwp_venv/bin/python

## Additional Resources

- [Compute Module 4 Setup Guide](https://github.com/whitejv/Interesting-Stuff/blob/main/Full%20Compute%20Module%204%20(Raspberry%20Pi)%20Setup%20_%20Imaging%20Guide.pdf)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [vsftpd Documentation](https://security.appspot.com/vsftpd.html)

## Contributing

For issues or improvements, please submit a pull request or open an issue in the GitHub repository.