#!/bin/bash
set -e
set -x

handle_error() {
    echo "An error occurred on line $1"
    exit 1
}

#Set error handling
trap 'handle_error $LINENO' ERR

# Deactivate virtual environment if it's active
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Remove Python virtual environment
if [ -d ~/mwp_venv ]; then
    rm -rf ~/mwp_venv
    echo "Removed Python virtual environment"
fi

# Remove pyrainbird directory if it exists
if [ -d ~/pyrainbird ]; then
    rm -rf ~/pyrainbird
    echo "Removed pyrainbird directory"
fi

# Remove activation script if it exists
if [ -f activate_mwp.sh ]; then
    rm activate_mwp.sh
    echo "Removed activation script"
fi

# Clean pip cache
if command -v pip &> /dev/null; then
    pip cache purge
    echo "Cleaned pip cache"
fi

echo "Python environment cleanup completed successfully."
