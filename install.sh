#!/bin/bash
# KNOCK Installer
set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT_URL="https://raw.githubusercontent.com/your-username/knock/main/knock.sh"

if [[ $EUID -ne 0 ]]; then
    echo "Requires root. Re-running with sudo..."
    exec sudo bash "$0" "$@"
    exit
fi

echo "Installing KNOCK..."
curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/KNOCK"
chmod +x "$INSTALL_DIR/KNOCK"
echo " KNOCK installed $INSTALL_DIR/KNOCK"
echo "Run 'sudo KNOCK --help' for usage."
