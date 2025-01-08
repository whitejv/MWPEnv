# MWP Environment Setup Guide

This guide provides instructions for setting up the Raspberry Pi Linux environment for the Milano Water Project (MWP). It covers initial Pi configuration, package updates, and installation of required services including SSH, FTP, JSON, and MQTT.

## Prerequisites

- Raspberry Pi 4/5 with fresh OS installation
- Monitor, keyboard, and mouse (for initial setup only)
- Network connection
- Basic familiarity with Linux commands

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

## Required Software Installation

### 1. Git (Required for Rapi-Lite)
```bash
sudo apt install git
```

### 2. Configuration Files
```bash
git clone https://github.com/whitejv/MWPEnv.git
cp MWPEnv/setup.sh .
chmod +x setup.sh
sudo ./setup.sh
sudo cp MilanoWaterProject/misc/vsftpd.conf /etc/.  # Verify content before copying
sudo reboot
```

### 3. OpenSSL Development Libraries
```bash
sudo apt-get install libssl-dev xutils-dev
```

### 4. FTP Server (vsftpd)
```bash
sudo apt install vsftpd
sudo cp /home/MilanoWaterProject/misc/vsftpd.conf /etc/.
sudo service vsftpd restart
```

FTP Configuration Options:
- Edit `/etc/vsftpd.conf` if manual configuration is needed:
  ```ini
  anonymous_enable=NO
  local_enable=YES
  write_enable=YES
  local_umask=022
  ```
- Optional: Restrict users to home directory:
  ```ini
  chroot_local_user=YES
  user_sub_token=$USER
  local_root=/home/$USER/FTP
  ```

### 5. Development Libraries
```bash
# JSON Library
sudo apt install libjson-c-dev

# CMake
sudo apt-get install cmake
```

### 6. MQTT Setup

Install Mosquitto:
```bash
sudo apt install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto.service
mosquitto -v
```

Install MQTT Client Library:
```bash
git clone https://github.com/eclipse/paho.mqtt.c.git
cd paho.mqtt.c
make
sudo make install
```

Configure Mosquitto:
```bash
sudo nano /etc/mosquitto/mosquitto.conf
# Add these lines:
# listener 1883
# allow_anonymous true
```

### 7. Python Dependencies

Update pip:
```bash
pip install --upgrade pip
```

Install Rainbird and MQTT libraries:
```bash
git clone https://github.com/allenporter/pyrainbird.git
cd pyrainbird
pip install -r requirements_dev.txt --ignore-requires-python
pip install . --ignore-requires-python
pip install paho-mqtt
cd ../
```

## Project Structure Setup

Create required directories:
```bash
mkdir -p FTP/files
chmod a-w FTP
mkdir MWPLogData
```

## Troubleshooting

If you encounter issues:
1. Check system logs: `journalctl -xe`
2. Verify service status: `systemctl status <service-name>`
3. Check configuration files for syntax errors
4. Ensure all prerequisites are installed
5. Verify network connectivity

## Additional Resources

- [Compute Module 4 Setup Guide](https://github.com/whitejv/Interesting-Stuff/blob/main/Full%20Compute%20Module%204%20(Raspberry%20Pi)%20Setup%20_%20Imaging%20Guide.pdf)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [vsftpd Documentation](https://security.appspot.com/vsftpd.html)

## Contributing

For issues or improvements, please submit a pull request or open an issue in the GitHub repository.
