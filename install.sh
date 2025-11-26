#!/bin/bash
# Installation script for klipper-nerdygriffin-macros
# This script will create a symlink and optionally configure moonraker

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PRINTER_DATA="${HOME}/printer_data"
CONFIG_DIR="${PRINTER_DATA}/config"
MOONRAKER_CONF="${CONFIG_DIR}/moonraker.conf"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  klipper-nerdygriffin-macros Installation${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if printer_data/config exists
if [ ! -d "${CONFIG_DIR}" ]; then
    echo -e "${YELLOW}Warning: ${CONFIG_DIR} not found.${NC}"
    echo -e "${YELLOW}Checking for alternate config path...${NC}"

    # Check for alternate paths
    if [ -d "${HOME}/klipper_config" ]; then
        CONFIG_DIR="${HOME}/klipper_config"
        echo -e "${GREEN}Found: ${CONFIG_DIR}${NC}"
    else
        echo -e "${RED}Error: Could not find Klipper config directory.${NC}"
        echo -e "${RED}Please ensure Klipper is installed correctly.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} Config directory: ${CONFIG_DIR}"

# Create symlink
SYMLINK_PATH="${CONFIG_DIR}/nerdygriffin-macros"
if [ -L "${SYMLINK_PATH}" ]; then
    echo -e "${YELLOW}⚠${NC}  Symlink already exists at ${SYMLINK_PATH}"
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "${SYMLINK_PATH}"
        echo -e "${GREEN}✓${NC} Removed existing symlink"
    else
        echo -e "${BLUE}ℹ${NC}  Keeping existing symlink"
    fi
fi

if [ ! -L "${SYMLINK_PATH}" ]; then
    ln -sf "${SCRIPT_DIR}/macros" "${SYMLINK_PATH}"
    echo -e "${GREEN}✓${NC} Created symlink: ${SYMLINK_PATH} -> ${SCRIPT_DIR}/macros"
fi

# Check moonraker.conf
echo ""
echo -e "${BLUE}Checking Moonraker configuration...${NC}"

if [ ! -f "${MOONRAKER_CONF}" ]; then
    echo -e "${YELLOW}⚠${NC}  moonraker.conf not found at ${MOONRAKER_CONF}"
    echo -e "${YELLOW}⚠${NC}  You will need to add the update_manager section manually."
else
    # Check if already configured
    if grep -q "update_manager klipper-nerdygriffin-macros" "${MOONRAKER_CONF}"; then
        echo -e "${GREEN}✓${NC} Moonraker update_manager already configured"
    else
        echo ""
        echo -e "${YELLOW}Moonraker update_manager not configured for this plugin.${NC}"
        echo ""
        read -p "Would you like to add it now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cat >> "${MOONRAKER_CONF}" << 'EOF'

[update_manager klipper-nerdygriffin-macros]
type: git_repo
path: ~/klipper-nerdygriffin-macros
origin: https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
primary_branch: main
is_system_service: False
managed_services: klipper
EOF
            echo -e "${GREEN}✓${NC} Added update_manager configuration to moonraker.conf"
            echo -e "${YELLOW}⚠${NC}  You will need to restart Moonraker for changes to take effect"
        else
            echo -e "${BLUE}ℹ${NC}  Skipped moonraker configuration"
            echo -e "${BLUE}ℹ${NC}  You can add it manually later - see README.md"
        fi
    fi
fi

# Display next steps
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Add these lines to your printer.cfg:"
echo ""
echo -e "${BLUE}   [include nerdygriffin-macros/auto_pid.cfg]${NC}"
echo -e "${BLUE}   [include nerdygriffin-macros/filament_management.cfg]${NC}"
echo -e "${BLUE}   [include nerdygriffin-macros/rename_existing.cfg]${NC}"
echo -e "${BLUE}   [include nerdygriffin-macros/save_config.cfg]${NC}"
echo -e "${BLUE}   [include nerdygriffin-macros/shutdown.cfg]${NC}"
echo -e "${BLUE}   [include nerdygriffin-macros/tacho_macros.cfg]${NC}"
echo ""
echo "2. Remove or comment out any duplicate includes of these files"
echo ""
echo "3. Restart Klipper:"
echo -e "   ${BLUE}sudo systemctl restart klipper${NC}"
echo ""
if grep -q "update_manager klipper-nerdygriffin-macros" "${MOONRAKER_CONF}" 2>/dev/null; then
    echo "4. Restart Moonraker (if you just added the update_manager config):"
    echo -e "   ${BLUE}sudo systemctl restart moonraker${NC}"
    echo ""
fi
echo -e "For more information, see: ${BLUE}${SCRIPT_DIR}/README.md${NC}"
echo ""
