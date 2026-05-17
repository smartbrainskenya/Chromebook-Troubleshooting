#!/bin/bash

# ==========================================================
# Chromebook Timezone & Firmware Troubleshooting Script
# ==========================================================
# Purpose:
# - Diagnose timezone synchronization problems
# - Verify firmware update utilities
# - Attempt basic ChromeOS update troubleshooting
# ==========================================================

clear

echo "==============================================="
echo " Chromebook Troubleshooting Utility"
echo " Author: Elvis Gatwara"
echo "==============================================="
echo ""

# Ensure script is executed as root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Please run this script as root."
    echo "Use: sudo bash $0"
    exit 1
fi

# ----------------------------------------------------------
# Step 1: Display System Information
# ----------------------------------------------------------
echo "[INFO] Collecting system information..."
echo ""
echo "Device Information:"
uname -a
echo ""
echo "ChromeOS Release Information:"
cat /etc/lsb-release 2>/dev/null
echo ""
echo "Firmware Information:"
chromeos-firmwareupdate -v 2>/dev/null
echo ""

# ----------------------------------------------------------
# Step 2: Check Network Connectivity
# ----------------------------------------------------------
echo "[INFO] Checking internet connectivity..."
ping -c 3 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Internet connection is active."
else
    echo "[WARNING] No internet connection detected."fi
echo ""

# ----------------------------------------------------------
# Step 3: Restart Time Synchronization Services
# ----------------------------------------------------------
echo "[INFO] Restarting time synchronization services..."
# Attempt NTP synchronization
ntpdate -u pool.ntp.org 2>/dev/null
if [ $? -eq 0 ]; then
    echo "[SUCCESS] System time synchronized successfully."
else
    echo "[WARNING] Failed to synchronize system time."
fi
echo ""

# ----------------------------------------------------------
# Step 4: Detect Update Utilities
# ----------------------------------------------------------
echo "[INFO] Searching for update-related executables..."
find / -iname "update" 2>/dev/null | head -20
echo ""

# ----------------------------------------------------------
# Step 5: Attempt Firmware Validation
# ----------------------------------------------------------
echo "[INFO] Running firmware validation..."
chromeos-firmwareupdate --host_only 2>/dev/null
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Firmware validation completed."
else
    echo "[WARNING] Firmware validation encountered issues."
fi
echo ""

# ----------------------------------------------------------
# Step 6: Force Timezone Refresh
# ----------------------------------------------------------
echo "[INFO] Refreshing timezone configuration..."
timedatectl set-ntp true 2>/dev/null
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Automatic time synchronization enabled."
else
    echo "[WARNING] Unable to enable automatic time synchronization."
fi
echo ""

# ----------------------------------------------------------
# Step 7: Final Status Report
# ----------------------------------------------------------echo "==============================================="
echo " Troubleshooting Completed"
echo "==============================================="
echo ""
echo "Recommendations:"
echo "1. Reboot the Chromebook after running this script."
echo "2. Verify timezone settings manually if issue persists."
echo "3. Recover ChromeOS using official recovery tools if updates fail."
echo "4. Unsupported devices may require Linux installation after AUE expiry."
echo ""
echo "Report Status: Problem Solved / Monitoring"
echo ""

exit 0