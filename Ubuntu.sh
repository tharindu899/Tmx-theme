#!/bin/bash

# Configuration
ERROR_LOG="$HOME/skip_errors.log"
THEME_DIR=""
THEME_NAME=""
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

# Error handling
log_error() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

# Output functions
status_msg() {
    local msg=$1
    local status=$2
    local symbol_color=$([ "$status" == "✓" ] && echo "$GREEN" || echo "$RED")
    local clean_msg=$(echo -e "$msg" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    local padding=$((COLUMNS - ${#clean_msg} - 12))
    printf "\r%b[ %s ]%b %b%-${padding}s\n" "$symbol_color" "$status" "$RESET" "$msg" ""
}

spinner() {
    local pid=$1 msg="$2"
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
    local msg="$1"
    shift
    ("$@") > /dev/null 2>> "$ERROR_LOG" &
    local pid=$!
    spinner $pid "$msg"
    local exit_code=$?
    status_msg "$msg" "$([ $exit_code -eq 0 ] && echo '✓' || echo '✗')"
}

# Theme selection
select_theme() {
    while true; do
        clear
        echo -e "${ART_COLOR}"
        cat << "EOF"
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

# Installation tasks
install_packages() {
    echo -e ""
    echo -e "${RED} ${BOLD}•••Installation might take some time•••${RESET}"
    echo -e "${BOLD}-------------------------------------------${RESET}"
    echo -e ""
    run_task "${YELLOW}Updating packages${RESET}" sudo apt-get update
    run_task "${YELLOW}Upgrading system${RESET}" sudo apt-get upgrade -y
    run_task "${BLUE}Installing core utilities${RESET}" sudo apt-get install zsh git wget curl python3 figlet lsd ncurses-bin -y
    run_task "${BLUE}Installing development tools${RESET}" sudo apt-get install neovim ripgrep lazygit -y
    run_task "${BLUE}Installing figlet and lolcat${RESET}" sudo apt-get install figlet ruby -y
    run_task "${BLUE}Installing additional tools${RESET}" sudo apt-get install build-essential zip gdu gdb fzf jq luarocks stylua yarn python3-pip clang zig -y
    run_task "${BLUE}Installing neovim Python support${RESET}" pip3 install neovim
    run_task "${BLUE}Installing neovim Node.js support${RESET}" sudo npm install -g neovim
    run_task "${BLUE}Installing lolcat${RESET}" sudo gem install lolcat
}

setup_fonts() {
    mkdir -p ~/.fonts
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ]; then
        run_task "${MAGENTA}Setting up fonts${RESET}" cp -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ~/.fonts/
        fc-cache -f ~/.fonts
    fi
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" ]; then
        sudo cp -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" "/usr/share/figlet/"
    fi
}

setup_configs() {
    local config_files=(
        ".zshrc"
        ".p10k.zsh"
        ".banner.sh"
        ".draw"
        ".draw.sh"
    )

    for file in "${config_files[@]}"; do
        run_task "${BLUE}Configuring ${file}${RESET}" cp -f "$HOME/Tmx-theme/$THEME_DIR/${file##*/}" "$HOME/$file"
    done
}

setup_zsh_plugins() {
    # Install Oh My Zsh core
    if [ ! -d ~/.oh-my-zsh/.git ]; then
        run_task "${CYAN}Installing Oh My Zsh${RESET}" \
            git clone --depth 1 "https://github.com/ohmyzsh/ohmyzsh.git" ~/.oh-my-zsh
    fi
    
    # Create required directories
    mkdir -p ~/.oh-my-zsh/{plugins,custom/themes}
    mkdir -p ~/.zsh/plugins
    
    # Install Powerlevel10k theme
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        run_task "${CYAN}Installing Powerlevel10k${RESET}" \
            git clone --depth 1 "https://github.com/romkatv/powerlevel10k.git" \
            ~/.oh-my-zsh/custom/themes/powerlevel10k
    fi

    # Standard plugins
    local ohmyzsh_plugins=(
        "zsh-users/zsh-completions"
        "zsh-users/zsh-history-substring-search"
        "bobthecow/git-flow-completion"
    )

    # System plugins
    local zsh_plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
    )

    # Install Oh My Zsh plugins
    for plugin in "${ohmyzsh_plugins[@]}"; do
        local name=${plugin##*/}
        local target_dir="$HOME/.oh-my-zsh/plugins/$name"
        [ -d "$target_dir" ] || run_task "${CYAN}Installing ${name}${RESET}" \
            git clone --depth 1 "https://github.com/$plugin" "$target_dir"
    done

    # Install zsh plugins
    for plugin in "${zsh_plugins[@]}"; do
        local name=${plugin##*/}
        local target_dir="$HOME/.zsh/plugins/$name"
        [ -d "$target_dir" ] || run_task "${CYAN}Installing ${name}${RESET}" \
            git clone --depth 1 "https://github.com/$plugin" "$target_dir"
    done
}

setup_astronvim() {
    [ -d ~/.config/nvim ] && run_task "${RED}Removing old nvim config${RESET}" rm -rf ~/.config/nvim
    run_task "${GREEN}Installing AstroNvim${RESET}" git clone --depth 1 "https://github.com/tharindu899/Astronvim-Termux.git" ~/.config/nvim
}

uninstall_theme() {
    echo -e "${RED}Uninstalling theme...${RESET}"
    rm -rf ~/.zshrc ~/.p10k.zsh ~/.banner.sh ~/.oh-my-zsh ~/.config/nvim ~/.fonts
    if [ -f /usr/share/figlet/ASCII-Shadow.flf ]; then
        sudo rm -f /usr/share/figlet/ASCII-Shadow.flf
    fi
    echo -e "${GREEN}Theme uninstalled successfully.${RESET}"
}

# Main execution
select_theme
install_packages
setup_fonts
setup_configs
setup_zsh_plugins
setup_astronvim

# Final step
run_task "${BOLD}Setting default shell${RESET}" sudo chsh -s $(which zsh) $USER
echo -e "\n${BOLD}${GREEN}✓ Setup complete! Log out and back in to see changes.${RESET}"
