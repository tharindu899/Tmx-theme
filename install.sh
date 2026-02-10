#!/bin/bash

# Configuration
ERROR_LOG="$HOME/skip_errors.log"
THEME_DIR=""
THEME_NAME=""
COLUMNS=$(tput cols)
MAX_RETRIES=3

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
    return $exit_code
}

# Network check
check_network() {
    echo -e "${CYAN}Checking network connectivity...${RESET}"
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${RED}No internet connection detected!${RESET}"
        echo -e "${YELLOW}Please check your network and try again.${RESET}"
        exit 1
    fi
}

# Fix Termux repositories
fix_termux_repos() {
    echo -e "${YELLOW}Fixing Termux repository configuration...${RESET}"
    
    # Backup current sources
    [ -f "$PREFIX/etc/apt/sources.list" ] && \
        cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.backup"
    
    # Use official mirrors
    cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
# Main Termux repository (Official mirrors)
deb https://packages.termux.dev/apt/termux-main stable main
EOF
    
    run_task "${BLUE}Updating repository information${RESET}" apt update
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

# Safe package installation with retry
safe_install() {
    local packages=("$@")
    local retry=0
    
    while [ $retry -lt $MAX_RETRIES ]; do
        if apt install -y "${packages[@]}" 2>> "$ERROR_LOG"; then
            return 0
        fi
        retry=$((retry + 1))
        [ $retry -lt $MAX_RETRIES ] && sleep 2
    done
    
    log_error "Failed to install: ${packages[*]}"
    return 1
}

# Installation tasks
install_packages() {
    echo -e ""
    echo -e "${RED} ${BOLD}•••It will take 10-20min•••${RESET}"
    echo -e "${BOLD}----------------------------${RESET}"
    echo -e ""
    
    # Fix repositories first
    fix_termux_repos
    
    # Update package lists
    run_task "${YELLOW}Updating package lists${RESET}" apt update
    
    # Essential packages in groups
    local essential=(zsh git wget curl ncurses-utils)
    local python=(python python-pip)
    local ruby=(ruby)
    local node=(nodejs)
    local dev=(neovim ripgrep)
    local tools=(figlet lolcat lsd logo-ls)
    
    # Install in stages with better error handling
    echo -e "${BLUE}Installing essential packages...${RESET}"
    safe_install "${essential[@]}" || echo -e "${YELLOW}Some essential packages failed${RESET}"
    
    echo -e "${BLUE}Installing Python...${RESET}"
    safe_install "${python[@]}" || echo -e "${YELLOW}Python installation had issues${RESET}"
    
    echo -e "${BLUE}Installing Ruby...${RESET}"
    safe_install "${ruby[@]}" || echo -e "${YELLOW}Ruby installation had issues${RESET}"
    
    echo -e "${BLUE}Installing Node.js...${RESET}"
    safe_install "${node[@]}" || echo -e "${YELLOW}Node.js installation had issues${RESET}"
    
    echo -e "${BLUE}Installing development tools...${RESET}"
    safe_install "${dev[@]}" || echo -e "${YELLOW}Some dev tools failed${RESET}"
    
    echo -e "${BLUE}Installing utilities...${RESET}"
    safe_install "${tools[@]}" || echo -e "${YELLOW}Some utilities failed${RESET}"
    
    # Optional: Advanced packages (allow failure)
    echo -e "${BLUE}Installing optional packages (failures are OK)...${RESET}"
    apt install -y lua-language-server lazygit fzf 2>> "$ERROR_LOG" || true
    
    # Install language-specific packages
    echo -e "${BLUE}Installing language packages...${RESET}"
    pip install --break-system-packages neovim 2>> "$ERROR_LOG" || true
    npm install -g neovim 2>> "$ERROR_LOG" || true
    gem install neovim lolcat 2>> "$ERROR_LOG" || true
}

setup_fonts() {
    mkdir -p ~/.termux
    run_task "${MAGENTA}Setting up fonts${RESET}" cp -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ~/.termux/
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" ]; then
        cp -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" "$PREFIX/share/figlet/" 2>> "$ERROR_LOG" || true
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

# Safe git clone with retry
safe_git_clone() {
    local url=$1
    local target=$2
    local retry=0
    
    while [ $retry -lt $MAX_RETRIES ]; do
        if git clone --depth 1 "$url" "$target" 2>> "$ERROR_LOG"; then
            return 0
        fi
        retry=$((retry + 1))
        rm -rf "$target"
        [ $retry -lt $MAX_RETRIES ] && sleep 2
    done
    
    log_error "Failed to clone: $url"
    return 1
}

setup_zsh_plugins() {
    # Install Oh My Zsh core
    if [ ! -d ~/.oh-my-zsh/.git ]; then
        run_task "${CYAN}Installing Oh My Zsh${RESET}" \
            safe_git_clone "https://github.com/ohmyzsh/ohmyzsh.git" ~/.oh-my-zsh
    fi
    
    # Create required directories
    mkdir -p ~/.oh-my-zsh/{plugins,custom/themes}
    mkdir -p $PREFIX/etc/.plugin
    
    # Install Powerlevel10k theme
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        run_task "${CYAN}Installing Powerlevel10k${RESET}" \
            safe_git_clone "https://github.com/romkatv/powerlevel10k.git" \
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
        if [ ! -d "$target_dir" ]; then
            run_task "${CYAN}Installing ${name}${RESET}" \
                safe_git_clone "https://github.com/$plugin" "$target_dir" || \
                echo -e "${YELLOW}Failed to install $name (continuing...)${RESET}"
        fi
    done

    # Install system plugins
    for plugin in "${etc_plugins[@]}"; do
        local name=${plugin##*/}
        local target_dir="$PREFIX/etc/.plugin/$name"
        if [ ! -d "$target_dir" ]; then
            run_task "${CYAN}Installing ${name}${RESET}" \
                safe_git_clone "https://github.com/$plugin" "$target_dir" || \
                echo -e "${YELLOW}Failed to install $name (continuing...)${RESET}"
        fi
    done
}

setup_astronvim() {
    [ -d ~/.config/nvim ] && run_task "${RED}Removing old nvim config${RESET}" rm -rf ~/.config/nvim
    run_task "${GREEN}Installing AstroNvim${RESET}" \
        safe_git_clone "https://github.com/tharindu899/Astronvim-Termux.git" ~/.config/nvim || \
        echo -e "${YELLOW}AstroNvim installation failed (optional)${RESET}"
}

uninstall_theme() {
    echo -e "${RED}Uninstalling theme...${RESET}"
    rm -rf ~/.termux ~/.zshrc ~/.p10k.zsh ~/.banner.sh ~/.oh-my-zsh ~/.config/nvim
    termux-reload-settings 2>/dev/null || true
    echo -e "${GREEN}Theme uninstalled successfully.${RESET}"
}

# Main execution
echo -e "${BOLD}${GREEN}Starting Tmx Theme Installation${RESET}\n"

# Check network first
check_network

select_theme
install_packages
setup_fonts
setup_configs
termux-reload-settings 2>/dev/null || true
setup_zsh_plugins
setup_astronvim

# Final step
run_task "${BOLD}Setting default shell${RESET}" chsh -s zsh

echo -e "\n${BOLD}${GREEN}✓ Setup complete!${RESET}"
echo -e "${YELLOW}Please restart Termux or run 'zsh' to apply changes.${RESET}"
echo -e "${CYAN}Check $ERROR_LOG for any warnings or errors.${RESET}\n"
