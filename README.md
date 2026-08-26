# 🎲 Dice Roller - KDE Plasma 6 Widget

A feature-rich polyhedral dice roller widget for KDE Plasma 6 on Fedora 44. Perfect for tabletop gaming enthusiasts who want quick access to dice rolls.

**Version:** 2.0.0 | **Plasma:** 6.0+ | **Qt:** 6.0+ | **Fedora:** 44+

## Features

✨ **Key Capabilities:**
- 🎲 Support for all standard polyhedral dice (d4, d6, d8, d10, d12, d20, d100)
- 📊 Roll multiple dice at once (1-10 dice per roll)
- 📝 Complete roll history with notation and individual results
- 🎯 Critical success/failure detection (natural 20s and 1s on d20)
- 🎨 Responsive UI that adapts to your KDE Plasma theme
- 🔄 Real-time updates and visual feedback
- 💾 Persistent roll history during session
- 🎛️ Simple, intuitive controls

## Quick Start

### System Requirements
- **OS:** Fedora 44
- **Desktop:** KDE Plasma 6.0+
- **Qt:** 6.0+
- **Python:** 3.11+ (system dependency)

### Installation

1. **Install dependencies:**
   ```bash
   sudo dnf install -y plasma-framework-devel kde-frameworks-devel
   ```

2. **Clone or download the repository:**
   ```bash
   git clone https://github.com/craigmcgrain-spec/Dice-Roller.git
   cd Dice-Roller
   ```

3. **Run the installation script:**
   ```bash
   chmod +x install-widget.sh
   ./install-widget.sh
   ```

4. **Add widget to your desktop:**
   - Right-click on desktop → "Add Widgets..."
   - Search for "Dice Roller"
   - Click to add

### Detailed Installation
See [FEDORA_PLASMA6_INSTALL.md](FEDORA_PLASMA6_INSTALL.md) for comprehensive installation instructions and troubleshooting.

## Usage

### Rolling Dice

1. **Select a dice type:** Click one of the dice buttons (d4, d6, d8, d10, d12, d20, d100)
2. **Set quantity:** Use the "Count" spinbox to roll multiple dice (1-10)
3. **Roll:** Click "🎲 Roll Dice" button
4. **View results:** The result display shows:
   - Total value
   - Notation (e.g., "1d20")
   - Individual roll values
   - Critical alerts (for d20)

### Features in Detail

#### Roll History
- Automatically saves your last 20 rolls
- Click "Clear History" to reset
- Shows notation and individual values for each roll

#### Critical Rolls (d20 only)
- **Natural 20:** Green highlight with "You're a Natural" message ✅
- **Natural 1:** Red highlight with "You're Fucked" message ❌

#### Theme Integration
- Automatically adapts to your current KDE Plasma theme
- Supports light and dark themes
- Respects system accent colors and fonts

## Documentation

- **[FEDORA_PLASMA6_INSTALL.md](FEDORA_PLASMA6_INSTALL.md)** - Complete installation and troubleshooting guide for Fedora 44
- **[PLASMA6_COMPATIBILITY.md](PLASMA6_COMPATIBILITY.md)** - Detailed compatibility changes and technical notes
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for contributing to the project

## Project Structure

```
Dice-Roller/
├── ui/
│   └── main.qml              # QML UI definition (Qt 6/Plasma 6)
├── src/
│   ├── DiceRoller.js         # Main dice rolling logic
│   ├── DiceParser.js         # Parse dice notation
│   ├── RollResult.js         # Result object handling
│   └── index.js              # Entry point
├── examples/
│   ├── 3d-dice-simulation.js # 3D simulation examples
│   └── dnd-scenarios.js      # D&D usage examples
├── metadata.desktop          # Desktop entry (Plasma 6)
├── metadata.json             # Plugin metadata (Plasma 6)
├── package.json              # Node.js package config
├── install-widget.sh         # Installation script (Plasma 6)
├── FEDORA_PLASMA6_INSTALL.md # Fedora 44 installation guide
├── PLASMA6_COMPATIBILITY.md  # Compatibility details
└── README.md                 # This file
```

## Development

### Setup Development Environment

```bash
# Install Node.js tools (Fedora 44)
sudo dnf install -y nodejs npm

# Install project dependencies
npm install

# Run tests
npm test

# Lint code
npm run lint
npm run lint:fix
```

### Modifying the Widget

The main widget interface is defined in `ui/main.qml` using QML (Qt Markup Language). Modify this file to change:
- Layout and UI components
- Styling and colors
- Interaction behavior

The dice logic is in `src/DiceRoller.js`. Modify this to:
- Add new dice types
- Change roll algorithms
- Enhance critical detection

### Testing Changes

After making changes:

```bash
# Rebuild Plasma cache
kbuildsycoca6

# Restart Plasma to reload widget
killall plasmashell
sleep 2
kstart6 plasmashell &

# Watch for errors
journalctl -f | grep plasma
```

## Compatibility

### Fedora 44 + KDE Plasma 6
- ✅ Full compatibility with latest Fedora and Plasma versions
- ✅ Qt 6.0+ support
- ✅ Modern QML syntax and features
- ✅ Kirigami 6 theming system

### Plasma 5 or Older
- ❌ Not compatible. Use version 1.1.0 for Plasma 5
- This is version 2.0.0 (Plasma 6 only)

### Dependencies
This widget requires:
- `plasma-framework-devel` (for widget framework)
- `kde-frameworks-devel` (for KDE components)
- Qt 6.0+ (automatically provided by Fedora 44)

For a complete list of system requirements, see [FEDORA_PLASMA6_INSTALL.md](FEDORA_PLASMA6_INSTALL.md).

## Troubleshooting

### Widget Doesn't Appear
1. Run `kbuildsycoca6`
2. Restart Plasma: `killall plasmashell && kstart6 plasmashell &`
3. Check logs: `journalctl -n 50 | grep plasma`

### Import Errors
Ensure dependencies are installed:
```bash
sudo dnf install -y plasma-framework-devel kde-frameworks-devel
```

### "kpackagetool6 not found"
Install the package:
```bash
sudo dnf install -y plasma-framework-devel
```

For more troubleshooting, see [FEDORA_PLASMA6_INSTALL.md](FEDORA_PLASMA6_INSTALL.md#troubleshooting).

## Version History

### v2.0.0 (Current) - Fedora 44 & KDE Plasma 6
- ✨ Full KDE Plasma 6 compatibility
- ✨ Fedora 44 optimization
- 🔄 Updated installation tools (kpackagetool6, kstart6)
- 📚 Comprehensive documentation for Fedora 44
- 🔧 Updated Node.js requirement to 16+
- 🎨 Enhanced theme integration

### v1.1.0 - KDE Plasma 5
- Initial release for Plasma 5
- Support for polyhedral dice
- Critical roll detection
- Roll history

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) file for details.

## Author

**Craig McGrain**
- GitHub: [@craigmcgrain-spec](https://github.com/craigmcgrain-spec)
- Email: craigmcgrain@gmail.com

## Support

- 🐛 **Report Issues:** [GitHub Issues](https://github.com/craigmcgrain-spec/Dice-Roller/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/craigmcgrain-spec/Dice-Roller/discussions)
- 📖 **Documentation:** See [FEDORA_PLASMA6_INSTALL.md](FEDORA_PLASMA6_INSTALL.md)

## Useful Resources

- [KDE Plasma 6 Developer Guide](https://develop.kde.org/plasma-6/)
- [Qt 6 Documentation](https://doc.qt.io/qt-6/)
- [KDE Frameworks Documentation](https://develop.kde.org/frameworks/)
- [Fedora 44 Release Notes](https://docs.fedoraproject.org/en-US/fedora/latest/)

---

**Happy Rolling! 🎲**

*Made for tabletop gamers, by a tabletop gamer.*
