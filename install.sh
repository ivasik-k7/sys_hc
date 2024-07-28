#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

SCRIPT_URL="https://raw.githubusercontent.com/ivasik-k7/sys_hc/main/sys_hc.sh"
SCRIPT_NAME="sys_hc.sh"
INSTALL_DIR="/usr/local/bin"
SYMLINK_NAME="monitor"

if [ ! -f "$SCRIPT_NAME" ]; then
    echo "Downloading system monitor script..."
    curl -s -o "$SCRIPT_NAME" "$SCRIPT_URL"
fi

chmod +x "$SCRIPT_NAME"

sudo ln -sf "$(pwd)/$SCRIPT_NAME" "$INSTALL_DIR/$SYMLINK_NAME"

echo "Installation complete. You can now run the script using the command: $SYMLINK_NAME"
