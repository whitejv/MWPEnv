#!/bin/bash
set -e
set -x

handle_error() {
    echo "An error occurred on line $1"
    exit 1
}

#Set error handling
trap 'handle_error $LINENO' ERR

# Check if we're running as the pi user
if [ "$(whoami)" != "pi" ]; then
    echo "This script should be run as the pi user"
    exit 1
fi

# Define paths
VENV_PATH="/home/pi/mwp_venv"
RAINBIRD_PATH="/home/pi/pyrainbird"

# Deactivate virtual environment if it's active
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Remove Python virtual environment
if [ -d "$VENV_PATH" ]; then
    # Check if we have permission to remove it
    if [ -w "$VENV_PATH" ]; then
        rm -rf "$VENV_PATH"
        echo "Removed Python virtual environment"
    else
        echo "Error: No permission to remove $VENV_PATH"
        exit 1
    fi
fi

# Remove pyrainbird directory if it exists
if [ -d "$RAINBIRD_PATH" ]; then
    # Check if we have permission to remove it
    if [ -w "$RAINBIRD_PATH" ]; then
        rm -rf "$RAINBIRD_PATH"
        echo "Removed pyrainbird directory"
    else
        echo "Error: No permission to remove $RAINBIRD_PATH"
        exit 1
    fi
fi

# Remove activation script if it exists
if [ -f activate_mwp.sh ]; then
    if [ -w activate_mwp.sh ]; then
        rm activate_mwp.sh
        echo "Removed activation script"
    else
        echo "Error: No permission to remove activate_mwp.sh"
        exit 1
    fi
fi

# Clean pip cache if pip is installed and we're in a user context
if command -v pip &> /dev/null; then
    pip cache purge
    echo "Cleaned pip cache"
fi

echo "Python environment cleanup completed successfully."
