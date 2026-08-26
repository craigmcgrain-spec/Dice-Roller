# KDE Plasma 6 Compatibility Changes

This document outlines all changes made to ensure compatibility with Fedora 44 and KDE Plasma 6.

## Version Updates

### Before (KDE Plasma 5)
- Widget Version: 1.1.0
- Plasma Framework: 5.x
- Qt Version: 5.x
- Node.js requirement: >=14.0.0
- Installation tools: `kpackagetool5`, `kstart5`, `kbuildsycoca5`

### After (KDE Plasma 6)
- Widget Version: 2.0.0
- Plasma Framework: 6.0+
- Qt Version: 6.0+
- Node.js requirement: >=16.0.0
- Installation tools: `kpackagetool6`, `kstart6`, `kbuildsycoca6`

## File Changes

### 1. `install-widget.sh` (Installation Script)
**Changes Made:**
- Updated `kpackagetool5` → `kpackagetool6`
- Updated `kstart5` → `kstart6`
- Updated `kbuildsycoca5` → `kbuildsycoca6`
- Changed dependency check from `kdebase-workspace-devel` to `plasma-framework-devel kde-frameworks-devel`
- Added variables for Plasma tools for easier maintenance
- Added Fedora 44 specific information in output
- Now copies `metadata.json` (previously omitted)
- Enhanced error messaging for Fedora 44 compatibility

**Compatibility Notes:**
- The script now dynamically uses Plasma 6 tools
- Handles both user and system-wide installations
- Supports Fedora 44's DNF package manager

### 2. `metadata.desktop` (Desktop Entry File)
**Changes Made:**
- Updated version from 1.1.0 to 2.0.0
- Added `X-KDE-Plasma-MinimumVersion=6.0` requirement
- Updated comment to mention KDE Plasma 6
- Added `Categories=Plasma;` for proper categorization in Plasma 6

**Compatibility Notes:**
- Plasma 6 recognizes this as a Plasma 6 only widget
- Won't appear in Plasma 5 installations

### 3. `metadata.json` (Plugin Metadata)
**Changes Made:**
- Updated version from 1.1.0 to 2.0.0
- Updated description to mention Fedora 44 and KDE Plasma 6
- Added `X-Plasma-MinimumPlasmaVersion` field: "6.0"
- Added `X-KDE-PluginInfo-Requires` field: "plasma-framework>=6.0"

**Compatibility Notes:**
- JSON metadata allows Plasma 6 to verify dependencies
- Prevents installation on incompatible systems

### 4. `package.json` (Node.js Package)
**Changes Made:**
- Updated version from 1.1.0 to 2.0.0
- Updated description to mention KDE Plasma 6 and Fedora 44
- Increased Node.js requirement from >=14.0.0 to >=16.0.0
- Added keywords: "kde", "plasma", "plasma6", "fedora"

**Compatibility Notes:**
- Node.js 16+ is required for all Fedora 44 development
- Version bump signals breaking changes in Plasma 6 compatibility

### 5. `ui/main.qml` (No Changes Required)
**Status:** ✅ Compatible with Plasma 6

**Analysis:**
- Uses standard QtQuick imports (compatible with Qt 6)
- Uses `org.kde.plasma.core` (Plasma Framework 6 compatible)
- Uses `org.kde.kirigami` (Kirigami 6 compatible)
- Uses `Plasmoid` API (compatible with Plasma 6)
- All QML properties and functions are Plasma 6 compatible

**Notes:**
- The QML code follows Plasma 6 best practices
- No import updates needed as imports are already Plasma 6 compatible
- Kirigami theming will automatically adapt to Fedora 44 KDE Plasma 6 theme

### 6. New File: `FEDORA_PLASMA6_INSTALL.md` (Installation Guide)
**Purpose:** Comprehensive installation and troubleshooting guide for Fedora 44 + KDE Plasma 6

**Contents Include:**
- System requirements verification
- Prerequisites and dependency installation
- Multiple installation methods (automatic and manual)
- Widget addition instructions for Plasma 6 interface
- Comprehensive troubleshooting section
- Uninstallation instructions
- Development setup guide
- Known limitations and support information

## System-Level Compatibility

### Fedora 44 Package Requirements
```bash
# Required packages for installation
plasma-framework-devel       # Plasma 6 development framework
kde-frameworks-devel        # KDE Frameworks for Plasma 6

# Optional development packages
kquickcharts-devel         # Charts in Plasma 6
kirigami2-devel            # Kirigami UI framework (already installed with plasma-framework)
```

### Qt/QML Module Changes
- Qt 5 → Qt 6 (automatic via Fedora 44 default)
- QML modules location: `/usr/lib64/qt6/qml/`
- Plasma QML modules location: `/usr/lib64/qt6/qml/org/kde/`

### Plugin Installation Path
- User-level: `~/.local/share/plasma/plasmoids/org.kde.plasma.diceroller/`
- System-level: `/usr/share/plasma/plasmoids/org.kde.plasma.diceroller/`

## Testing Checklist

- [x] Installation script updated for Plasma 6 tools
- [x] Metadata files updated with Plasma 6 requirements
- [x] Version numbers bumped to 2.0.0
- [x] Node.js requirements updated for Fedora 44
- [x] QML imports verified compatible with Qt 6
- [x] Installation guide created for Fedora 44
- [x] Error messages updated with helpful guidance
- [x] Troubleshooting documentation added

## Breaking Changes

1. **Minimum Plasma Version:** Now requires KDE Plasma 6.0+ (Plasma 5 not supported)
2. **Minimum Qt Version:** Now requires Qt 6.0+ (Qt 5 not supported)
3. **Minimum Node.js:** Now requires Node.js 16+ (if developing)
4. **Installation Tools:** Previous scripts/tools won't work, must use Plasma 6 tools

## Migration Path

### For Users on Plasma 5
To migrate from Plasma 5 to Plasma 6 with this widget:

1. Ensure you have Fedora 44 installed
2. Upgrade to KDE Plasma 6
3. Uninstall the previous widget version (if present)
4. Install this version (2.0.0) using the updated installation script
5. Add the widget to your desktop/panel

### For Developers
To update your local development environment:

1. Update to Fedora 44
2. Install KDE Plasma 6 packages
3. Update Node.js to 16+
4. Pull latest version of this repository
5. Run `npm install` to update dependencies

## References

- [KDE Plasma 6 Documentation](https://develop.kde.org/plasma-6/)
- [Fedora 44 Release Notes](https://docs.fedoraproject.org/en-US/fedora/latest/)
- [Qt 6 Migration Guide](https://doc.qt.io/qt-6/migration-guide.html)
- [KDE Framework 6 Documentation](https://develop.kde.org/frameworks/)

## Support

For issues specific to Fedora 44 or KDE Plasma 6 compatibility:
- Check the FEDORA_PLASMA6_INSTALL.md troubleshooting section
- Open an issue on GitHub with details about your system and error messages
- Include output from: `plasmaversion`, `qmake --version`, and relevant journal logs

---

**Last Updated:** 2026-08-26
**Widget Version:** 2.0.0
**Plasma Framework:** 6.0+
**Fedora Version:** 44+
