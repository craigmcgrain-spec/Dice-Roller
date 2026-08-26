# Dice Roller - KDE Plasma 6 Installation Guide (Fedora 44)

This guide provides detailed instructions for installing the Dice Roller widget on Fedora 44 with KDE Plasma 6.

## System Requirements

- **Operating System:** Fedora 44
- **Desktop Environment:** KDE Plasma 6.0 or later
- **Qt Version:** 6.0 or later
- **Node.js:** 16.0.0 or later (optional, only for development)
- **Python:** 3.11 or later (system dependency)

## Prerequisites

### Install Required Dependencies

Before installing the widget, ensure you have the necessary KDE Plasma 6 development packages:

```bash
# Install KDE Plasma 6 development dependencies
sudo dnf install -y plasma-framework-devel kde-frameworks-devel

# Optional: Install additional KDE Plasma 6 tools
sudo dnf install -y kquickcharts-devel kirigami2-devel
```

### Verify Plasma Version

Check that you have KDE Plasma 6 installed:

```bash
plasmaversion
```

Output should show `Plasma 6.x.x`.

## Installation Methods

### Method 1: Automatic Installation (Recommended)

Run the provided installation script:

```bash
cd ~/path/to/Dice-Roller
chmod +x install-widget.sh
./install-widget.sh
```

The script will:
1. Check for required KDE Plasma 6 tools
2. Remove any existing installation
3. Copy widget files to `~/.local/share/plasma/plasmoids/`
4. Install the widget using `kpackagetool6`
5. Rebuild the Plasma cache with `kbuildsycoca6`
6. Restart the Plasma Shell

### Method 2: Manual Installation

If the automatic script fails, you can install manually:

```bash
# Create the installation directory
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller

# Copy all widget files
cp metadata.desktop ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller/
cp metadata.json ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller/
cp -r ui ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller/
cp -r src ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller/

# Install with kpackagetool6
kpackagetool6 -i ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller

# Rebuild cache
kbuildsycoca6

# Restart Plasma
killall plasmashell
sleep 2
kstart plasmashell &
```

## Adding the Widget to Your Desktop/Panel

1. Right-click on your desktop or panel
2. Select "**Add Widgets...**" or "**Edit Panel...**" (depending on context)
3. Search for "**Dice Roller**"
4. Click on "Dice Roller" to add it
5. Configure the widget size by resizing or using widget settings

## Troubleshooting

### Widget Doesn't Appear After Installation

1. **Force rebuild the Plasma cache:**
   ```bash
   kbuildsycoca6
   ```

2. **Restart Plasma Shell:**
   ```bash
   killall plasmashell
   sleep 2
   kstart plasmashell &
   ```

3. **Check for errors in logs:**
   ```bash
   journalctl -n 50 -f | grep -i plasma
   ```

### "kpackagetool6 not found" Error

Install the missing package:

```bash
sudo dnf install -y plasma-framework-devel kde-frameworks-devel
```

### Widget Appears but with Errors

Check if your Qt/QML environment is properly set up:

```bash
# Verify Qt 6 is installed
qmake --version

# Check for missing QML modules
ls /usr/lib64/qt6/qml/
```

If issues persist, check system logs:

```bash
journalctl -xe | grep -i plasma
dmesg | grep -i error
```

### Import Errors in QML

If you see errors related to `QtQuick` or `org.kde.plasma` imports:

1. Ensure `kdebase-workspace` and `plasma-framework` are installed:
   ```bash
   sudo dnf install -y kdebase-workspace plasma-framework
   ```

2. Verify the QML module paths:
   ```bash
   echo $QML2_IMPORT_PATH
   ```

## Uninstalling

To remove the Dice Roller widget:

```bash
# Using kpackagetool6
kpackagetool6 -r org.kde.plasma.diceroller

# Or manually remove the directory
rm -rf ~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller

# Rebuild cache
kbuildsycoca6
```

## Development

### Setting Up Development Environment

```bash
# Install Node.js development tools (Fedora 44)
sudo dnf install -y nodejs npm

# Install project dependencies
npm install

# Run tests
npm test

# Run linter
npm run lint
```

### Plasma 6 QML Development

When modifying the QML code (`ui/main.qml`), note the following Plasma 6 changes:

- **Import paths:** Use `org.kde.plasma.core` instead of deprecated imports
- **API changes:** Check [KDE Plasma 6 documentation](https://develop.kde.org/plasma-6/) for changes
- **Qt 6 compatibility:** Ensure all code uses Qt 6.0+ APIs

### Testing Changes

After modifying QML:

```bash
# Rebuild cache
kbuildsycoca6

# Restart Plasma to see changes
killall plasmashell
sleep 2
kstart plasmashell &

# Monitor logs for errors
journalctl -f | grep plasma
```

## System Configuration Files

The widget uses the following configuration:

- **Installation:** `~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller/`
- **Metadata:** `metadata.json` and `metadata.desktop`
- **UI Definition:** `ui/main.qml` (QML/Qt 6)
- **Logic:** `src/DiceRoller.js`, `src/DiceParser.js`, `src/RollResult.js`

## Known Limitations

- This version requires KDE Plasma 6.0 or later
- Qt 5 is no longer supported (use previous versions for Plasma 5)
- Some visual effects may differ due to Kirigami 6 styling changes

## Support and Issues

For issues, questions, or suggestions:

- GitHub Issues: https://github.com/craigmcgrain-spec/Dice-Roller/issues
- GitHub Discussions: https://github.com/craigmcgrain-spec/Dice-Roller/discussions

## Version Information

- **Widget Version:** 2.0.0
- **Plasma Framework:** 6.0+
- **Qt Version:** 6.0+
- **Fedora Version:** 44+
- **License:** MIT

## License

This project is licensed under the MIT License. See LICENSE file for details.
