#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

INSTALL_DIR="/usr/local/bin"
SYMLINK_NAME="monitor"
SCRIPT_NAME="sys_hc.sh"

if [ -L "$INSTALL_DIR/$SYMLINK_NAME" ]; then
    echo "Removing symbolic link..."
    sudo rm "$INSTALL_DIR/$SYMLINK_NAME"
    echo "Symbolic link removed."
else
    echo "Symbolic link not found."
fi

if [ -f "$SCRIPT_NAME" ]; then
    echo "Removing script file..."
    rm "$SCRIPT_NAME"
    echo "Script file removed."
else
    echo "Script file not found."
fi

echo "Uninstallation complete."
