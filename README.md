# Chromebook Timezone & Firmware Troubleshooting Script
[![Bash](https://img.shields.io/badge/Bash-4.0+-blue.svg)](https://www.gnu.org/software/bash/)
[![ChromeOS](https://img.shields.io/badge/ChromeOS-100+-green.svg)](https://www.chromium.org/chromium-os/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Elvis%20Gatwara-orange.svg)](https://github.com/egatwara)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Script Output](#script-output)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

---

## 📖 Overview

A lightweight, automated diagnostic and remediation bash script designed to identify and resolve common **timezone synchronization** and **firmware-related issues** on Chrome OS devices. Built for IT support teams, education fleet managers, and enterprise administrators.

**⚠️ Important:** This script requires **root access** and works best on Chromebooks in **Developer Mode**, with **Crostini (Linux)** enabled, or running **ChromeOS Flex**.


## ✨ Features

- ✅ **System Information Gathering** - Collects device, OS, and firmware details
- ✅ **Network Connectivity Testing** - Verifies internet access for NTP and updates
- ✅ **Time Synchronization** - Restarts NTP services and forces timezone refresh
- ✅ **Firmware Validation** - Checks firmware update utilities and status
- ✅ **Update Utility Detection** - Locates ChromeOS update-related executables
- ✅ **Automated Diagnostics** - Provides clear SUCCESS/WARNING/ERROR indicators
- ✅ **Actionable Recommendations** - Offers post-troubleshooting next steps

---

## 📋 Prerequisites

### System Requirements

| Requirement | Details |
|-------------|---------|
| **ChromeOS Version** | 100 or later (Stable/LTS channel) |
| **Access Level** | Root/sudo privileges required |
| **Environment** | Developer Mode, Crostini, or ChromeOS Flex |
| **Network** | Active internet connection |
| **Shell** | Bash 4.0+ |

### Enable Required Features

**For Standard Chromebooks:**
1. Enable Developer Mode (⚠️ wipes local data)
2. Press `Ctrl + Alt + T` to open Crosh
3. Type `shell` to access bash

**For Crostini (Linux):**
1. Go to Settings → Linux (Beta) → Turn On
2. Open Linux terminal
3. Install required tools: `sudo apt install ntpdate`

---

## 📥 Installation

### Option 1: Clone Repository

```bash
git clone https://github.com/gamm3r96/chromebook-troubleshoot.git
cd chromebook-troubleshoot
```

### Option 2: Download Directly

```bash
curl -O https://raw.githubusercontent.com/gamm3r96/chromebook-troubleshoot/main/chromebook_troubleshoot.sh
```

### Option 3: Manual Creation

1. Create a new file: `nano chromebook_troubleshoot.sh`
2. Paste the script content
3. Save with `Ctrl + O`, then exit with `Ctrl + X`

### Make Executable

```bash
chmod +x chromebook_troubleshoot.sh
```

## 🚀 Usage

### Basic Execution

```bash
# Run with sudo (recommended)
sudo bash chromebook_troubleshoot.sh

# Or if already root
./chromebook_troubleshoot.sh
```

### Save Output to Log File

```bash
# Save to timestamped log
sudo bash chromebook_troubleshoot.sh | tee ~/Downloads/chromebook_diag_$(date +%Y%m%d_%H%M%S).log

# Or redirect all output
sudo bash chromebook_troubleshoot.sh > ~/Downloads/diag_log.txt 2>&1
```

### Script Flow

The script executes 7 diagnostic steps:

1. **System Information** - Device, OS, and firmware details
2. **Network Check** - Internet connectivity verification
3. **Time Sync Restart** - NTP service restart and synchronization
4. **Update Utilities** - Search for ChromeOS update executables
5. **Firmware Validation** - Run firmware update checks
6. **Timezone Refresh** - Enable automatic time synchronization
7. **Final Report** - Summary and recommendations

## 📊 Script Output

### Success Indicators

```
[SUCCESS] Internet connection is active.
[SUCCESS] System time synchronized successfully.
[SUCCESS] Firmware validation completed.
```

### Warning Indicators

```
[WARNING] No internet connection detected.
[WARNING] Failed to synchronize system time.
[WARNING] Firmware validation encountered issues.
```

### Error Indicators

```
[ERROR] Please run this script as root.
Use: sudo bash scriptname.sh
```


## 🔧 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| `Permission denied` | Run with `sudo bash scriptname.sh` |
| `command not found: chromeos-firmwareupdate` | Command only available in Developer Mode shell |
| `ntpdate: command not found` | Install with `sudo apt install ntpdate` (Crostini) |
| All steps show warnings | Device may be managed/locked; contact IT admin |
| Script won't execute | Ensure executable bit is set: `chmod +x scriptname.sh` |

### Verify Environment

```bash
# Check if you have shell access
crosh> shell

# Verify ChromeOS version
cat /etc/lsb-release

# Check current user
whoami

# Verify sudo access
sudo whoami  # Should return "root"
```

## 🔒 Security Considerations

### Best Practices

- ✅ **Test first** on non-production devices
- ✅ **Review script** before execution
- ✅ **Backup data** before troubleshooting
- ✅ **Get authorization** for managed devices
- ✅ **Audit logs** after execution

### What This Script Does NOT Do

- ❌ Does NOT modify firmware
- ❌ Does NOT install packages without permission
- ❌ Does NOT delete user data
- ❌ Does NOT bypass enterprise policies
- ❌ Does NOT make permanent system changes

### Data Privacy

This script:
- Collects system information (OS version, firmware, hostname)
- Tests network connectivity
- Checks time synchronization status
- **Does NOT** collect personal files, browsing history, or credentials

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Bash best practices
- Add comments for complex logic
- Test on multiple ChromeOS versions
- Maintain backward compatibility
- Update documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Elvis Gatwara

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👤 Author

**Elvis Gatwara**

- GitHub: [@gamm3r96](https://github.com/gamm3r96)
- Role: IT Support & Systems Administrator


## 🙏 Acknowledgments

- Chromium OS Project
- ChromeOS Community
- IT Support Teams worldwide
- Contributors and testers


## 📞 Support

For issues, questions, or contributions:

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/yourusername/chromebook-troubleshoot/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/chromebook-troubleshoot/discussions)
- 📧 **Email**: [elvisgatwara@gmail.com]


## 🔗 Related Resources

- [ChromeOS Developer Guide](https://www.chromium.org/chromium-os/developer-guide/)
- [ChromeOS Firmware Documentation](https://www.chromium.org/chromium-os/chromiumos-design-docs/firmware)
- [NTP Project](https://www.ntp.org/)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)

<div align="center">

**Made with ❤️ for IT Support Teams**

[⬆ Back to Top](#chromebook-timezone--firmware-troubleshooting-script)

</div>

