#!/bin/bash

# KDE Plasma Dice Roller Installation Script
# For Fedora 44 with KDE Plasma

set -e

echo "🎲 Installing Dice Roller Plasma Widget..."

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Installation paths
LOCAL_INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.plasma.diceroller"
SYSTEM_INSTALL_DIR="/usr/share/plasma/plasmoids/org.kde.plasma.diceroller"

# Check for required tools
echo "Checking for required tools..."
if ! command -v kpackagetool5 &> /dev/null; then
    echo "❌ kpackagetool5 not found. Installing KDE development tools..."
    sudo dnf install -y kdebase-workspace-devel
fi

# Uninstall if already exists
echo "Cleaning up old installations..."
kpackagetool5 -r org.kde.plasma.diceroller 2>/dev/null || true

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$LOCAL_INSTALL_DIR"

# Copy files
echo "Copying widget files..."
cp metadata.desktop "$LOCAL_INSTALL_DIR/"
cp -r ui "$LOCAL_INSTALL_DIR/" 2>/dev/null || true
cp -r src "$LOCAL_INSTALL_DIR/" 2>/dev/null || true

# Install the widget
echo "Installing widget with kpackagetool5..."
kpackagetool5 -i "$LOCAL_INSTALL_DIR"

# Rebuild Plasma cache
echo "Rebuilding Plasma cache..."
kbuildsycoca5

# Restart Plasma Shell
echo "Restarting Plasma Shell..."
killall plasmashell 2>/dev/null || true
sleep 2
kstart5 plasmashell &

# Wait for Plasma to restart
sleep 3

echo "✅ Installation complete!"
echo ""
echo "📖 Next steps:"
echo "1. Right-click on your desktop or panel"
echo "2. Select 'Add Widgets'"
echo "3. Search for 'Dice Roller'"
echo "4. Click to add the widget"
echo ""
echo "If the widget doesn't appear:"
echo "  - Run: kbuildsycoca5"
echo "  - Run: killall plasmashell && kstart5 plasmashell &"
echo "  - Check: journalctl -n 50 | grep plasma"
