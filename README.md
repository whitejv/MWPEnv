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

## Automated Installation (Recommended)

The fastest way to set up your environment is using our automated setup script:

```bash
# Clone the repository
git clone https://github.com/whitejv/MWPEnv.git

# Copy and make the setup script executable
cp MWPEnv/setup.sh .
chmod +x setup.sh

# Run the setup script
sudo ./setup.sh
```

The script will automatically:
- Install and configure all required packages
- Set up FTP server
- Configure MQTT
- Install Python dependencies
- Create necessary project directories

After the script completes, verify the installation by checking the status of key services:
```bash
systemctl status vsftpd
systemctl status mosquitto
```

If you encounter any issues with the automated setup, refer to the manual installation steps below for troubleshooting.

## Manual Installation Steps (Alternative Method)

If you need to install components individually or troubleshoot the automated installation, follow these steps:

### 1. Git (Required for Rapi-Lite)
```bash
sudo apt install git
```

[Rest of the manual installation steps remain the same...]

[Previous sections for OpenSSL, FTP Server, Development Libraries, MQTT Setup, Python Dependencies, and Project Structure Setup remain unchanged]

## Troubleshooting

If you encounter issues with the automated script:
1. Check the script output for error messages
2. Run individual commands manually to identify the failing component
3. Check system logs: `journalctl -xe`
4. Verify service status: `systemctl status <service-name>`
5. Check configuration files for syntax errors
6. Ensure all prerequisites are installed
7. Verify network connectivity

## Additional Resources

- [Compute Module 4 Setup Guide](https://github.com/whitejv/Interesting-Stuff/blob/main/Full%20Compute%20Module%204%20(Raspberry%20Pi)%20Setup%20_%20Imaging%20Guide.pdf)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [vsftpd Documentation](https://security.appspot.com/vsftpd.html)

## Contributing

For issues or improvements, please submit a pull request or open an issue in the GitHub repository.
