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

# Install Rust (required for some Python packages)
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

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
pip install --no-dependencies -r requirements_dev.txt --ignore-requires-python
pip install . --ignore-requires-python
pip install paho-mqtt
cd "$ORIGINAL_DIR" || exit 1

# Create activation script for future use
echo '#!/bin/bash
source ~/mwp_venv/bin/activate' > activate_mwp.sh
chmod +x activate_mwp.sh

# Deactivate virtual environment
deactivate

echo "Python environment setup completed successfully."
