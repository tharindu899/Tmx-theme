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
    run_task "${YELLOW}it will take 10-20min${RESET}"
    run_task "${YELLOW}Updating packages${RESET}" apt update
    run_task "${YELLOW}Upgrading system${RESET}" apt upgrade -y
    run_task "${BLUE}Installing pkg-nala${RESET}" pkg install nala -y
    run_task "${BLUE}Installing core utilities${RESET}" pkg install zsh git wget curl python micro figlet lsd logo-ls ncurses-utils -y
    run_task "${BLUE}Installing development tools${RESET}" pkg install neovim lua-language-server ripgrep lazygit -y
    run_task "${BLUE}Installing figlet and lolcat${RESET}" pkg install figlet ruby -y
    run_task "${BLUE}Installing niovim tool${RESET}" apt install build-essential zip termux-api gdu gdb gdbserver gh fd fzf neovim lua-language-server jq-lsp luarocks stylua ripgrep yarn python-pip ccls clang zig rust-analyzer -y
    run_task "${BLUE}Installing neovim${RESET}" pip install neovim
    run_task "${BLUE}Installing nmp neovim${RESET}" npm install -g neovim
    run_task "${BLUE}Installing gem neovim${RESET}" gem install neovim
    run_task "${BLUE}Installing lolcat gem (for animation support)${RESET}" gem install lolcat
}

setup_fonts() {
    mkdir -p ~/.termux
    run_task "${MAGENTA}Setting up fonts${RESET}" cp -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ~/.termux/
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" ]; then
        cp -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" "$PREFIX/share/figlet/"
    fi
}

setup_configs() {
    local config_files=(
        ".termux/termux.properties"
        ".termux/colors.properties"
        ".termux/font.ttf"
        ".zshrc"
        ".p10k.zsh"
        ".banner.sh"
        ".draw"
        ".draw.sh"
        "../usr/etc/zshrc"
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
    mkdir -p $PREFIX/etc/.plugin
    
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

    # System-wide plugins
    local etc_plugins=(
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

    # Install system plugins
    for plugin in "${etc_plugins[@]}"; do
        local name=${plugin##*/}
        local target_dir="$PREFIX/etc/.plugin/$name"
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
    rm -rf ~/.termux ~/.zshrc ~/.p10k.zsh ~/.banner.sh ~/.oh-my-zsh ~/.config/nvim
    termux-reload-settings
    echo -e "${GREEN}Theme uninstalled successfully.${RESET}"
}

# Main execution
select_theme
install_packages
setup_fonts
setup_configs
termux-reload-settings
setup_zsh_plugins
setup_astronvim

# Final step
run_task "${BOLD}Setting default shell${RESET}" chsh -s zsh
echo -e "\n${BOLD}${GREEN}✓ Setup complete! Restart your terminal or run 'zsh'.${RESET}"
