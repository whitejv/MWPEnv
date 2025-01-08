# MWPEnv
The RPI LINUX environment to support MWP Project includes initial PI setup, Package Update, SSH, FTP, JSON, and MQTT

This setup assumes a raspberry pi 4/5 with a freshly installed OS. The first couple of steps require physical login to
the pi using keyboard and mouse. After initial setup is complete the remainder can be done via a remote login.

## Enable Remote Access
- -> On the MAC --> ssh pi@xxx.local --> PW: raspberry --> sudo raspi_config --> Select Interfaces and enable VNC
- -> On the RPI --> From the Raspbery Logo --> Preferences --> Raspberry PI Configuration --> Interface Tab --> VNC: Enable

## Update all Packages (if necessary)
- -> sudo apt update
- -> sudo apt full-upgrade
- -> sudo reboot

    
## The Remainder of the Setup & Configuration Can Be Done via Remote Connection 

## Intsall Git (if using Rapi-Lite)
- -> sudo apt install git

## Install Required Configuration files
- -> git clone https://github.com/whitejv/MWPEnv.git
- -> cp MWPEnv/setup.sh .
- -> chmod +x setup.sh
- -> sudo ./setup.sh
- -> sudo cp MilanoWaterProject/misc/vsftpd.conf /etc/. (diff to verify content prior to copy)
- -> sudo reboot

### Install OpenSSL for C/C++ programs

- -> sudo apt-get install libssl-dev
- -> sudo apt-get install xutils-dev

### Install FTP Daemon

- -> sudo apt install vsftpd
- -> sudo cp /home/MilanoWaterProject/misc/vsftpd.conf /etc/.
-   -> sudo nano /etc/vsftpd.conf (if doing it manually)
-    ->>anonymous_enable=NO
-    ->>local_enable=YES
-    ->>write_enable=YES
-    ->>local_umask=022
- Uncomment the following lines if needed to restrict user to home director;
-    ->>#chroot_local_user=YES
-    ->>#user_sub_token=$USER
-    ->>#local_root=/home/$USER/FTP
- Create the necessary directories if needed
-    ->>#mkdir -p /home/<user>/FTP/files
-    ->>#chmod a-w /home/<user>/FTP
- -> sudo service vsftpd restart

### Install JSON Lib

- -> sudo apt install libjson-c-dev

### Install CMake

- -> sudo apt-get install cmake

### Install Mosquitto MQTT Service

- -> sudo apt install -y mosquitto mosquitto-clients
- -> sudo systemctl enable mosquitto.service
- -> mosquitto -v

### Install MQTT and Update Config File and Application Libraries

- -> git clone https://github.com/eclipse/paho.mqtt.c.git
- -> cd paho.mqtt.c
- -> make
- -> sudo make install
- -> cd /etc/mosquitto
- -> sudo nano mosquitto.conf
- ->>> add: listener 1883
- ->>> add: allow_anonymous true
- -> cd ~

## Update PIP
- ->pip install --upgrade pip

## Install the Python LIBs & Py Rainbird Project
- -> git clone https://github.com/allenporter/pyrainbird.git
- -> cd pyrainbird
- -> pip install -r requirements_dev.txt --ignore-requires-python
- -> pip install . --ignore-requires-python
- -> pip install paho-mqtt
- -> cd ../

## Create Project Directories
- -> mkdir -p FTP/files
- -> chmod a-w FTP
- -> mkdir MWPLogData

## Useful Documents
### See the Interesting Stuff Repository for the following docs that are helpful
[
](https://github.com/whitejv/Interesting-Stuff/blob/main/Full%20Compute%20Module%204%20(Raspberry%20Pi)%20Setup%20_%20Imaging%20Guide.pdf)
