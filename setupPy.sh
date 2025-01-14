#!/bin/bash
set -e
set -x

handle_error() {
    echo "An error occurred on line $1"
    exit 1
}

#Set error handling
trap 'handle_error $LINENO' ERR

# Save original directory
ORIGINAL_DIR=$(pwd)

# Define virtual environment path explicitly
VENV_PATH="/home/pi/mwp_venv"

# Install Rust (required for some Python packages)
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install Python virtual environment package (only operation needing sudo)
sudo apt-get install -y python3-venv python3-full

# Create virtual environment with explicit path
echo "Creating virtual environment at $VENV_PATH"
python3 -m venv $VENV_PATH

# Ensure proper ownership of virtual environment
chown -R pi:pi $VENV_PATH

# Verify virtual environment creation
if [ ! -d "$VENV_PATH" ]; then
    echo "Failed to create virtual environment"
    exit 1
fi

# Activate virtual environment
source "$VENV_PATH/bin/activate"

# Verify activation
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Failed to activate virtual environment"
    exit 1
fi

# Install Python dependencies within virtual environment
pip install --upgrade pip

# Ensure Rust is in PATH for the virtual environment
source "$HOME/.cargo/env"

# Clone and install pyrainbird
if [ -d "pyrainbird" ]; then
    rm -rf pyrainbird
fi
git clone https://github.com/allenporter/pyrainbird.git
cd pyrainbird || exit 1
pip install --no-dependencies -r requirements_dev.txt --ignore-requires-python
pip install . --ignore-requires-python
pip install paho-mqtt
cd "$ORIGINAL_DIR" || exit 1

# Create activation script for future use and ensure proper ownership
echo '#!/bin/bash
source "'$VENV_PATH'/bin/activate"' > activate_mwp.sh
chmod +x activate_mwp.sh
chown pi:pi activate_mwp.sh

# Deactivate virtual environment
deactivate

echo "Python environment setup completed successfully."
