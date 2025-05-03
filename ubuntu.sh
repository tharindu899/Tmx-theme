#!/bin/bash

# Ubuntu Theme & Zsh Installer Script
# Adapted from Termux script for Ubuntu/Debian-based systems

# Configuration
ERROR_LOG="$HOME/ubuntu_theme_errors.log"
THEME_DIR=""
COLUMNS=$(tput cols)

# Color Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Spinner and ASCII Art Colors
ART_COLOR=$CYAN
SPINNER_COLOR=$MAGENTA

log_error() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

status_msg() {
    local msg=$1; local status=$2
    local symbol_color=$([ "$status" == "✓" ] && echo "$GREEN" || echo "$RED")
    local clean_msg=$(echo -e "$msg" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    local padding=$((COLUMNS - ${#clean_msg} - 12))
    printf "\r%b[ %s ]%b %b%-${padding}s\n" "$symbol_color" "$status" "$RESET" "$msg" ""
}

spinner() {
    local pid=$1; local msg="$2"
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    while kill -0 $pid 2>/dev/null; do
        for c in "${spin[@]}"; do
            printf "\r%b[%s]%b %b" "$SPINNER_COLOR" "$c" "$RESET" "$msg"
            sleep 0.1
        done
    done
    wait $pid
}

run_task() {
    local msg="$1"; shift
    ("$@") > /dev/null 2>> "$ERROR_LOG" &
    local pid=$!
    spinner $pid "$msg"
    local exit_code=$?
    status_msg "$msg" "$([ $exit_code -eq 0 ] && echo '✓' || echo '✗')"
}

select_theme() {
    while true; do
        clear
        echo -e "${ART_COLOR}"
        cat << 'EOF'
  ████████╗██╗  ██╗███████╗███████╗███╗   ███╗███████╗
  ╚══██╔══╝██║  ██║██╔════╝██╔════╝████╗ ████║██╔════╝
     ██║   ███████║█████╗  █████╗  ██╔████╔██║█████╗  
     ██║   ██╔══██║██╔══╝  ██╔══╝  ██║╚██╔╝██║██╔══╝  
     ██║   ██║  ██║███████╗███████╗██║ ╚═╝ ██║███████╗
     ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝╚══════╝
EOF
        echo -e "${RESET}"
        echo -e "${CYAN}  ${BOLD}1) Black Theme${RESET}"
        echo -e "${CYAN}  ${BOLD}2) Color Theme${RESET}"
        echo -e "${RED}  ${BOLD}3) Uninstall${RESET}"
        echo -e "${YELLOW}  ${BOLD}4) Exit${RESET}"
        echo
        read -p "$(echo -e "${BOLD}${MAGENTA}Select theme (1-4): ${RESET}")" choice

        case "$choice" in
            1) THEME_DIR="black"; return 0 ;;  
            2) THEME_DIR="color"; return 0 ;;  
            3) uninstall_theme; exit 0 ;;      
            4) echo -e "${RED}Exiting...${RESET}"; exit 0 ;; 
            *) echo -e "${RED}Invalid option. Please enter 1-4.${RESET}"; sleep 1 ;;  
        esac
    done
}

install_packages() {
    run_task "Updating APT cache" sudo apt update -y
    run_task "Upgrading system" sudo apt upgrade -y
    run_task "Installing core packages" sudo apt install -y zsh git wget curl python3 python3-pip neovim ruby figlet lolcat nala build-essential zip fd-find fzf jq luarocks clang
}

setup_configs() {
    local config_files=(
        ".zshrc"
        ".p10k.zsh"
        ".banner.sh"
        ".draw.sh"
    )
    for file in "${config_files[@]}"; do
        run_task "Configuring $file" cp -f "$PWD/$THEME_DIR/$file" "$HOME/$file"
    done
}

setup_fonts_and_theme() {
    # Powerlevel10k font prompt instructions
    echo -e "\n${BOLD}Please install a Nerd Font (e.g. MesloLGS NF) in your terminal emulator for proper Powerlevel10k rendering.${RESET}\n"
}

setup_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        run_task "Installing Oh My Zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    fi
    run_task "Installing Powerlevel10k theme" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
}

uninstall_theme() {
    echo -e "${RED}Uninstalling theme...${RESET}"
    rm -f $HOME/.zshrc $HOME/.p10k.zsh $HOME/.banner.sh $HOME/.draw.sh
    rm -rf $HOME/.oh-my-zsh
    echo -e "${GREEN}Theme uninstalled successfully.${RESET}"
}

# Main Execution
select_theme
install_packages
setup_fonts_and_theme
setup_configs
setup_oh_my_zsh
run_task "Setting default shell to zsh" sudo chsh -s $(which zsh) $USER

echo -e "\n${BOLD}${GREEN}✓ Setup complete! Please restart your terminal or run 'zsh'.${RESET}"
