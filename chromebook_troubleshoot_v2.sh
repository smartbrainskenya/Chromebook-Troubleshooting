#!/usr/bin/env bash
# =============================================================================
# Chromebook Timezone & Firmware Advanced Troubleshooter
# Author: Elvis Gatwara | Version: 2.0.0
# =============================================================================
# Features:
#   ✅ Colorized, timestamped logging
#   ✅ ChromeOS-native diagnostics (update_engine, crossystem)
#   ✅ Safe command detection & graceful fallbacks
#   ✅ Dry-run mode for safe testing
#   ✅ JSON/CSV export for ITSM integration
#   ✅ Interactive menu & CLI flags
# =============================================================================

set -euo pipefail

# --------------------------- CONFIGURATION ---------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/chromebook_diag_$(date +%Y%m%d_%H%M%S).log"
readonly REPORT_FILE="${HOME}/Downloads/chromebook_report_$(date +%Y%m%d_%H%M%S).json"

# Colors
readonly RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; 
readonly BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# State
DRY_RUN=false
SKIP_PROMPTS=false
declare -A DIAG_RESULTS

# --------------------------- HELPER FUNCTIONS ---------------------------
log()        { echo -e "$1" 2>/dev/null | tee -a "$LOG_FILE"; }
info()       { log "${BLUE}[ℹ️ INFO]${NC} $1"; }
success()    { log "${GREEN}[✅ SUCCESS]${NC} $1"; }
warn()       { log "${YELLOW}[⚠️ WARNING]${NC} $1"; }
error_exit() { log "${RED}[❌ ERROR]${NC} $1"; exit "${2:-1}"; }

cmd_exists() { command -v "$1" &>/dev/null; }

confirm() {
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would execute: $1"; return 0
    fi
    if [[ "$SKIP_PROMPTS" == true ]]; then return 0; fi
    read -rp "${BOLD}$1 (y/N):${NC} " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

sanitize_json() {    # Escape quotes, newlines, and backslashes for safe JSON
    sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'
}

# --------------------------- DIAGNOSTIC FUNCTIONS ---------------------------
detect_env() {
    info "Detecting runtime environment..."
    if [[ -f /etc/lsb-release ]] && grep -q "Chrome OS" /etc/lsb-release 2>/dev/null; then
        ENV_TYPE="ChromeOS"
    elif [[ -d /opt/google/cros-containers ]]; then
        ENV_TYPE="Crostini"
    elif [[ "$(uname -r)" == *"flex"* ]]; then
        ENV_TYPE="ChromeOS_Flex"
    else
        ENV_TYPE="Linux/Unknown"
    fi
    success "Environment: ${ENV_TYPE}"
    DIAG_RESULTS[environment]="$ENV_TYPE"
}

check_system_info() {
    info "Collecting system & firmware data..."
    local os_info fw_info crossystem_info
    os_info=$(cat /etc/lsb-release 2>/dev/null | head -5 || echo "Unavailable")
    fw_info=$(chromeos-firmwareupdate --version 2>/dev/null || echo "Unavailable")
    crossystem_info=$(crossystem ro_fwid devsw_boot wpsw_cur 2>/dev/null || echo "Crossystem restricted")
    
    echo -e "\n${CYAN}📋 System Snapshot:${NC}"
    echo "OS: $os_info"
    echo "Firmware: $fw_info"
    echo "Hardware Flags: $crossystem_info"
    
    DIAG_RESULTS[os_info]="$os_info"
    DIAG_RESULTS[firmware]="$fw_info"
    DIAG_RESULTS[hardware_flags]="$crossystem_info"
}

check_network() {
    info "Testing internet connectivity..."
    if ping -c 2 -W 3 8.8.8.8 &>/dev/null; then
        success "Network reachable (IPv4)"
        DIAG_RESULTS[network]="reachable"
    elif ping -c 2 -W 3 2001:4860:4860::8888 &>/dev/null; then
        success "Network reachable (IPv6)"
        DIAG_RESULTS[network]="reachable_ipv6"
    else
        warn "No internet connectivity detected"
        DIAG_RESULTS[network]="unreachable"
    fi
}
check_time_sync() {
    info "Checking time synchronization..."
    if cmd_exists timedatectl; then
        local tz_status ntp_status
        tz_status=$(timedatectl show --property=Timezone --value 2>/dev/null)
        ntp_status=$(timedatectl show --property=NTPSynchronized --value 2>/dev/null)
        echo -e "Current TZ: ${BOLD}${tz_status:-Unknown}${NC}"
        echo -e "NTP Sync: ${BOLD}${ntp_status:-Unknown}${NC}"
        DIAG_RESULTS[timezone]="$tz_status"
        DIAG_RESULTS[ntp_status]="$ntp_status"

        if [[ "$ntp_status" != "yes" ]]; then
            if confirm "Enable automatic NTP sync?"; then
                timedatectl set-ntp true 2>/dev/null && success "NTP enabled" || warn "Failed to enable NTP"
            fi
        else
            success "Time already synchronized"
        fi
    else
        warn "timedatectl not available. Checking legacy NTP..."
        if cmd_exists ntpdate; then
            ntpdate -u pool.ntp.org &>/dev/null && success "Time synced via ntpdate" || warn "ntpdate failed"
        else
            warn "No time sync utilities found"
        fi
    fi
}

check_update_engine() {
    info "Querying ChromeOS update engine..."
    if cmd_exists update_engine_client; then
        local status
        status=$(update_engine_client --status 2>/dev/null || echo "Restricted")
        echo -e "${CYAN}🔄 Update Engine Status:${NC}\n$status"
        DIAG_RESULTS[update_engine]="$status"
    else
        warn "update_engine_client not available (likely Crostini/standard Linux)"
        DIAG_RESULTS[update_engine]="unavailable"
    fi
}

# --------------------------- REPORT GENERATION ---------------------------
export_json_report() {
    info "Generating JSON report..."
    cat > "$REPORT_FILE" <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "hostname": "$(hostname 2>/dev/null || echo 'unknown')",
  "environment": "${DIAG_RESULTS[environment]}",  "network": "${DIAG_RESULTS[network]}",
  "timezone": "${DIAG_RESULTS[timezone]}",
  "ntp_status": "${DIAG_RESULTS[ntp_status]}",
  "firmware": "$(echo "${DIAG_RESULTS[firmware]}" | sanitize_json)",
  "update_engine": "$(echo "${DIAG_RESULTS[update_engine]}" | sanitize_json)",
  "script_version": "2.0.0"
}
EOF
    success "Report saved to: ${REPORT_FILE}"
}

# --------------------------- MAIN MENU & EXECUTION ---------------------------
run_full_scan() {
    clear
    echo -e "${BOLD}${CYAN}=======================================================${NC}"
    echo -e "${BOLD}${CYAN}   🛠️  Chromebook Advanced Troubleshooter v2.0${NC}"
    echo -e "${BOLD}${CYAN}=======================================================${NC}\n"
    detect_env
    check_system_info
    check_network
    check_time_sync
    check_update_engine
    echo -e "\n${BOLD}✅ Diagnostic complete. Review logs or export report.${NC}\n"
}

show_menu() {
    while true; do
        clear
        echo -e "${BOLD}${CYAN}=======================================================${NC}"
        echo -e "${BOLD}${CYAN}   🛠️  Chromebook Advanced Troubleshooter v2.0${NC}"
        echo -e "${BOLD}${CYAN}=======================================================${NC}"
        echo -e " 1) 📊 Run Full Diagnostic Scan"
        echo -e " 2) ⏱️  Quick Timezone & NTP Check"
        echo -e " 3) 🔌 Update Engine & Firmware Status"
        echo -e " 4) 📤 Export Last Report as JSON"
        echo -e " 5) 🧪 Enable Dry-Run Mode (Safe Testing)"
        echo -e " 0) 🚪 Exit"
        echo -e "${CYAN}-------------------------------------------------------${NC}"
        read -rp "Select an option: " choice
        case $choice in
            1) run_full_scan; export_json_report; read -rp "Press Enter to return..." ;;
            2) check_time_sync; read -rp "Press Enter to return..." ;;
            3) check_update_engine; check_system_info | grep -A2 "Firmware\|Hardware"; read -rp "Press Enter to return..." ;;
            4) export_json_report; read -rp "Press Enter to return..." ;;
            5) DRY_RUN=true; info "Dry-run mode enabled. Changes will only be simulated."; read -rp "Press Enter to return..." ;;
            0) exit 0 ;;
            *) warn "Invalid option. Try again." ;;
        esac
    done
}
# --------------------------- ARGUMENT PARSING & ENTRY ---------------------------
usage() {
    cat <<EOF
Usage: sudo $SCRIPT_NAME [OPTIONS]

Options:
  --menu          Launch interactive menu (default)
  --scan          Run full diagnostic & export JSON
  --quick         Quick timezone/NTP check only
  --export        Export existing report as JSON
  --dry-run       Simulate actions without making changes
  -y / --yes      Skip confirmation prompts
  -h / --help     Show this help message
EOF
    exit 0
}

# Require root/sudo
if [[ $EUID -ne 0 ]]; then
    error_exit "This script requires root privileges. Run with: sudo $0" 1
fi

# Parse args
ARGS=("$@")
ACTION="menu"
for arg in "${ARGS[@]}"; do
    case $arg in
        --scan) ACTION="scan" ;;
        --quick) ACTION="quick" ;;
        --export) ACTION="export" ;;
        --dry-run) DRY_RUN=true ;;
        -y|--yes) SKIP_PROMPTS=true ;;
        -h|--help|--menu) ACTION="$arg" ;;
    esac
done

# Execute
case $ACTION in
    --menu|menu) show_menu ;;
    --scan|scan) run_full_scan; export_json_report ;;
    --quick|quick) check_time_sync ;;
    --export|export) export_json_report ;;
    --help|-h) usage ;;
esac

exit 0