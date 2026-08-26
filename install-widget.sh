#!/bin/bash

# KDE Plasma Dice Roller Installation Script
# For Fedora 44 with KDE Plasma 6

set -e

echo "🎲 Installing Dice Roller Plasma Widget..."

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Installation paths
LOCAL_INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.plasma.diceroller"
SYSTEM_INSTALL_DIR="/usr/share/plasma/plasmoids/org.kde.plasma.diceroller"

# Check for required tools
echo "Checking for required tools..."
PLASMA_TOOL="kpackagetool6"
PLASMA_CMD="kstart6"
SYCOCA_CMD="kbuildsycoca6"

if ! command -v $PLASMA_TOOL &> /dev/null; then
    echo "❌ $PLASMA_TOOL not found. Installing KDE Plasma 6 development tools..."
    echo "This requires: kde-frameworks-devel and plasma-framework-devel"
    sudo dnf install -y plasma-framework-devel kde-frameworks-devel
fi

# Uninstall if already exists
echo "Cleaning up old installations..."
$PLASMA_TOOL --type Plasma/Applet -r org.kde.plasma.diceroller 2>/dev/null || true
rm -rf "$LOCAL_INSTALL_DIR"
rm -rf "$HOME/.local/share/kpackage/generic/org.kde.plasma.diceroller"

# Install the widget (install directly from source dir with correct type)
echo "Installing widget with $PLASMA_TOOL..."
$PLASMA_TOOL --type Plasma/Applet -i "$SCRIPT_DIR"

# Rebuild Plasma cache
echo "Rebuilding Plasma cache..."
$SYCOCA_CMD

# Restart Plasma Shell
echo "Restarting Plasma Shell..."
PID=$(pgrep -f plasmashell | head -1)
if [ -n "$PID" ]; then
    kill "$PID" 2>/dev/null || true
fi
sleep 2
$PLASMA_CMD plasmashell &

# Wait for Plasma to restart
sleep 3

echo "✅ Installation complete!"
echo ""
echo "📖 Next steps:"
echo "1. Right-click on your desktop or panel"
echo "2. Select 'Add Widgets...'"
echo "3. Search for 'Dice Roller'"
echo "4. Click to add the widget"
echo ""
echo "If the widget doesn't appear:"
echo "  - Run: $SYCOCA_CMD"
echo "  - Run: killall plasmashell && $PLASMA_CMD plasmashell &"
echo "  - Check: journalctl -n 50 | grep plasma"
echo ""
echo "For Fedora 44 with KDE Plasma 6:"
echo "  - Ensure you have plasma-framework-devel installed"
echo "  - Use Python 3.11+ for any scripting needs"
