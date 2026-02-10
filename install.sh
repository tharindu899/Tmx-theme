#!/bin/bash

# Configuration
ERROR_LOG="$HOME/skip_errors.log"
THEME_DIR=""
COLUMNS=$(tput cols)
MAX_RETRIES=3
TIMEOUT=30

# Color Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ART_COLOR=$CYAN
SPINNER_COLOR=$MAGENTA

# Initialize error log
echo "=== Tmx Theme Installation Log ===" > "$ERROR_LOG"
echo "Started: $(date)" >> "$ERROR_LOG"
echo "" >> "$ERROR_LOG"

# Error handling
log_error() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

log_warning() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$ERROR_LOG"
}

log_success() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1" >> "$ERROR_LOG"
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

# Network and connectivity checks
check_network() {
    echo -e "${CYAN}Checking network connectivity...${RESET}"
    
    # Check basic connectivity
    if ! ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${RED}No internet connection detected!${RESET}"
        echo -e "${YELLOW}Please check your network and try again.${RESET}"
        log_error "Network check failed - no connectivity"
        exit 1
    fi
    
    # Check DNS resolution
    if ! ping -c 1 -W 5 google.com >/dev/null 2>&1; then
        echo -e "${YELLOW}DNS resolution issues detected${RESET}"
        log_warning "DNS resolution may be slow"
        
        # Try to fix DNS
        if [ -f "$PREFIX/etc/resolv.conf" ]; then
            echo "nameserver 8.8.8.8" > "$PREFIX/etc/resolv.conf"
            echo "nameserver 8.8.4.4" >> "$PREFIX/etc/resolv.conf"
        fi
    fi
    
    echo -e "${GREEN}Network OK${RESET}"
    log_success "Network connectivity verified"
}

# Fix Termux repositories completely
fix_termux_repos() {
    echo -e "${YELLOW}Fixing Termux repository configuration...${RESET}"
    log_success "Starting repository fix"
    
    # Backup current sources
    if [ -f "$PREFIX/etc/apt/sources.list" ]; then
        cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.backup.$(date +%s)"
        log_success "Backed up current sources.list"
    fi
    
    # Use multiple official mirrors for redundancy
    cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
# Official Termux repository
deb https://packages.termux.dev/apt/termux-main stable main

# Backup mirrors (commented out, uncomment if main fails)
# deb https://grimler.se/termux-packages-24/apt/termux-main stable main
# deb https://termux.librehat.com/apt/termux-main stable main
EOF
    
    log_success "Repository configuration updated"
    
    # Clear apt cache
    apt clean 2>> "$ERROR_LOG"
    rm -rf "$PREFIX/var/lib/apt/lists/"* 2>> "$ERROR_LOG"
    
    # Update with retries
    local retry=0
    while [ $retry -lt 3 ]; do
        echo -e "${BLUE}Updating package lists (attempt $((retry + 1))/3)...${RESET}"
        if apt update 2>> "$ERROR_LOG"; then
            log_success "Package lists updated successfully"
            return 0
        fi
        retry=$((retry + 1))
        [ $retry -lt 3 ] && sleep 3
    done
    
    log_error "Failed to update package lists after 3 attempts"
    return 1
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

# Safe package installation with better error handling
safe_install() {
    local packages=("$@")
    local failed_packages=()
    
    log_success "Attempting to install: ${packages[*]}"
    
    # Try installing all packages together first
    if apt install -y "${packages[@]}" 2>> "$ERROR_LOG"; then
        log_success "Successfully installed: ${packages[*]}"
        return 0
    fi
    
    log_warning "Batch install failed, trying individual packages"
    
    # If batch fails, try one by one
    for pkg in "${packages[@]}"; do
        echo -e "${BLUE}Installing $pkg...${RESET}"
        if apt install -y "$pkg" 2>> "$ERROR_LOG"; then
            log_success "Installed: $pkg"
        else
            log_error "Failed to install: $pkg"
            failed_packages+=("$pkg")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_warning "Failed packages: ${failed_packages[*]}"
        echo -e "${YELLOW}Some packages failed to install: ${failed_packages[*]}${RESET}"
        echo -e "${YELLOW}Continuing with available packages...${RESET}"
    fi
    
    return 0
}

# Installation tasks with comprehensive error handling
install_packages() {
    echo -e ""
    echo -e "${RED} ${BOLD}•••Installation will take 10-20 minutes•••${RESET}"
    echo -e "${BOLD}-------------------------------------------${RESET}"
    echo -e ""
    
    # Fix repositories first
    fix_termux_repos || {
        echo -e "${RED}Failed to fix repositories. Continuing anyway...${RESET}"
    }
    
    # Upgrade existing packages
    echo -e "${YELLOW}Upgrading existing packages...${RESET}"
    apt upgrade -y 2>> "$ERROR_LOG" || log_warning "Upgrade had issues"
    
    # Core packages (absolutely required)
    echo -e "${BOLD}${GREEN}=== Installing Core Packages ===${RESET}"
    safe_install zsh git wget curl ncurses-utils
    
    # Programming languages
    echo -e "${BOLD}${GREEN}=== Installing Programming Languages ===${RESET}"
    safe_install python python-pip
    safe_install ruby
    safe_install nodejs
    
    # Development tools
    echo -e "${BOLD}${GREEN}=== Installing Development Tools ===${RESET}"
    safe_install neovim ripgrep
    
    # Utilities and visual tools
    echo -e "${BOLD}${GREEN}=== Installing Utilities ===${RESET}"
    safe_install figlet lsd logo-ls
    
    # Optional advanced packages (failures are acceptable)
    echo -e "${BOLD}${CYAN}=== Installing Optional Packages ===${RESET}"
    echo -e "${YELLOW}(Failures here are not critical)${RESET}"
    
    apt install -y lua-language-server 2>> "$ERROR_LOG" || log_warning "lua-language-server not available"
    apt install -y lazygit 2>> "$ERROR_LOG" || log_warning "lazygit not available"
    apt install -y fzf 2>> "$ERROR_LOG" || log_warning "fzf not available"
    apt install -y gh 2>> "$ERROR_LOG" || log_warning "gh not available"
    apt install -y fd 2>> "$ERROR_LOG" || log_warning "fd not available"
    
    # Language-specific packages with error handling
    echo -e "${BOLD}${CYAN}=== Installing Language Packages ===${RESET}"
    
    # Python packages
    if command -v pip >/dev/null 2>&1; then
        echo -e "${BLUE}Installing Python neovim...${RESET}"
        pip install --break-system-packages neovim 2>> "$ERROR_LOG" || {
            log_warning "pip install neovim failed"
            echo -e "${YELLOW}Python neovim installation failed (optional)${RESET}"
        }
    fi
    
    # Node packages
    if command -v npm >/dev/null 2>&1; then
        echo -e "${BLUE}Installing Node.js neovim...${RESET}"
        npm install -g neovim 2>> "$ERROR_LOG" || {
            log_warning "npm install neovim failed"
            echo -e "${YELLOW}Node.js neovim installation failed (optional)${RESET}"
        }
    fi
    
    # Ruby gems
    if command -v gem >/dev/null 2>&1; then
        echo -e "${BLUE}Installing Ruby gems...${RESET}"
        gem install lolcat 2>> "$ERROR_LOG" || log_warning "gem install lolcat failed"
        gem install neovim 2>> "$ERROR_LOG" || log_warning "gem install neovim failed"
    fi
    
    log_success "Package installation completed"
}

setup_fonts() {
    echo -e "${MAGENTA}Setting up fonts...${RESET}"
    mkdir -p ~/.termux
    
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ]; then
        cp -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ~/.termux/ 2>> "$ERROR_LOG"
        log_success "Font copied to ~/.termux/"
    else
        log_error "Font file not found: $HOME/Tmx-theme/$THEME_DIR/font.ttf"
    fi
    
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" ]; then
        cp -f "$HOME/Tmx-theme/$THEME_DIR/ASCII-Shadow.flf" "$PREFIX/share/figlet/" 2>> "$ERROR_LOG"
        log_success "ASCII font installed"
    else
        log_warning "ASCII-Shadow.flf not found"
    fi
}

setup_configs() {
    echo -e "${BLUE}Setting up configuration files...${RESET}"
    
    local config_files=(
        ".termux/termux.properties"
        ".termux/colors.properties"
        ".zshrc"
        ".p10k.zsh"
        ".banner.sh"
        ".draw"
        ".draw.sh"
    )

    for file in "${config_files[@]}"; do
        local source="$HOME/Tmx-theme/$THEME_DIR/${file##*/}"
        local target="$HOME/$file"
        
        # Create directory if needed
        mkdir -p "$(dirname "$target")"
        
        if [ -f "$source" ]; then
            cp -f "$source" "$target" 2>> "$ERROR_LOG"
            log_success "Configured: $file"
        else
            log_warning "Source file not found: $source"
        fi
    done
    
    # System zshrc
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/zshrc" ]; then
        cp -f "$HOME/Tmx-theme/$THEME_DIR/zshrc" "$PREFIX/etc/zshrc" 2>> "$ERROR_LOG"
        log_success "System zshrc configured"
    fi
}

# Safe git clone with comprehensive retry logic
safe_git_clone() {
    local url=$1
    local target=$2
    local retry=0
    local max_retries=5
    
    log_success "Attempting to clone: $url"
    
    while [ $retry -lt $max_retries ]; do
        echo -e "${BLUE}Cloning (attempt $((retry + 1))/$max_retries): ${url##*/}${RESET}"
        
        # Remove target if exists from previous failed attempt
        [ -d "$target" ] && rm -rf "$target"
        
        # Try to clone with timeout
        if timeout $TIMEOUT git clone --depth 1 "$url" "$target" 2>> "$ERROR_LOG"; then
            log_success "Successfully cloned: ${url##*/}"
            return 0
        fi
        
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            local wait_time=$((retry * 2))
            echo -e "${YELLOW}Clone failed, waiting ${wait_time}s before retry...${RESET}"
            sleep $wait_time
        fi
    done
    
    log_error "Failed to clone after $max_retries attempts: $url"
    return 1
}

setup_zsh_plugins() {
    echo -e "${BOLD}${GREEN}=== Setting up Zsh and Plugins ===${RESET}"
    
    # Install Oh My Zsh core
    if [ ! -d ~/.oh-my-zsh/.git ]; then
        echo -e "${CYAN}Installing Oh My Zsh...${RESET}"
        if safe_git_clone "https://github.com/ohmyzsh/ohmyzsh.git" ~/.oh-my-zsh; then
            log_success "Oh My Zsh installed"
        else
            log_error "Oh My Zsh installation failed - trying alternative method"
            # Try alternative installation
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>> "$ERROR_LOG" || {
                log_error "Alternative Oh My Zsh installation also failed"
                echo -e "${RED}Oh My Zsh installation failed. Check your network.${RESET}"
                return 1
            }
        fi
    else
        echo -e "${GREEN}Oh My Zsh already installed${RESET}"
    fi
    
    # Create required directories
    mkdir -p ~/.oh-my-zsh/plugins
    mkdir -p ~/.oh-my-zsh/custom/themes
    mkdir -p $PREFIX/etc/.plugin
    
    # Install Powerlevel10k theme
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        echo -e "${CYAN}Installing Powerlevel10k...${RESET}"
        safe_git_clone "https://github.com/romkatv/powerlevel10k.git" \
            ~/.oh-my-zsh/custom/themes/powerlevel10k || {
            log_error "Powerlevel10k installation failed"
            echo -e "${RED}Powerlevel10k installation failed${RESET}"
        }
    else
        echo -e "${GREEN}Powerlevel10k already installed${RESET}"
    fi

    # Define plugins
    declare -A plugins
    plugins=(
        ["zsh-completions"]="zsh-users/zsh-completions::~/.oh-my-zsh/plugins/zsh-completions"
        ["zsh-history-substring-search"]="zsh-users/zsh-history-substring-search::~/.oh-my-zsh/plugins/zsh-history-substring-search"
        ["git-flow-completion"]="bobthecow/git-flow-completion::~/.oh-my-zsh/plugins/git-flow-completion"
        ["zsh-syntax-highlighting"]="zsh-users/zsh-syntax-highlighting::$PREFIX/etc/.plugin/zsh-syntax-highlighting"
        ["zsh-autosuggestions"]="zsh-users/zsh-autosuggestions::$PREFIX/etc/.plugin/zsh-autosuggestions"
    )
    
    # Install plugins
    for plugin_name in "${!plugins[@]}"; do
        IFS='::' read -r repo target <<< "${plugins[$plugin_name]}"
        target=$(eval echo "$target")  # Expand variables
        
        if [ ! -d "$target" ]; then
            echo -e "${CYAN}Installing $plugin_name...${RESET}"
            if safe_git_clone "https://github.com/$repo" "$target"; then
                log_success "Installed: $plugin_name"
            else
                log_warning "Failed to install: $plugin_name (continuing...)"
                echo -e "${YELLOW}Failed to install $plugin_name (non-critical)${RESET}"
            fi
        else
            echo -e "${GREEN}$plugin_name already installed${RESET}"
        fi
    done
    
    log_success "Zsh plugins setup completed"
}

setup_astronvim() {
    echo -e "${GREEN}Setting up AstroNvim...${RESET}"
    
    if [ -d ~/.config/nvim ]; then
        echo -e "${YELLOW}Removing old nvim config...${RESET}"
        rm -rf ~/.config/nvim
        log_success "Old nvim config removed"
    fi
    
    if safe_git_clone "https://github.com/tharindu899/Astronvim-Termux.git" ~/.config/nvim; then
        log_success "AstroNvim installed successfully"
    else
        log_warning "AstroNvim installation failed (optional feature)"
        echo -e "${YELLOW}AstroNvim installation failed (optional)${RESET}"
    fi
}

uninstall_theme() {
    echo -e "${RED}${BOLD}Uninstalling Tmx Theme...${RESET}"
    
    local items=(
        ~/.termux
        ~/.zshrc
        ~/.p10k.zsh
        ~/.banner.sh
        ~/.draw
        ~/.draw.sh
        ~/.oh-my-zsh
        ~/.config/nvim
        $PREFIX/etc/.plugin
    )
    
    for item in "${items[@]}"; do
        if [ -e "$item" ]; then
            echo -e "${YELLOW}Removing: $item${RESET}"
            rm -rf "$item"
        fi
    done
    
    termux-reload-settings 2>/dev/null || true
    echo -e "${GREEN}Theme uninstalled successfully.${RESET}"
    log_success "Theme uninstalled"
}

# Main execution
main() {
    echo -e "${BOLD}${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Tmx Theme Installation Script       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${RESET}\n"
    
    # Pre-flight checks
    check_network || exit 1
    
    # Theme selection
    select_theme || exit 0
    
    # Installation steps
    echo -e "\n${BOLD}${CYAN}Starting installation...${RESET}\n"
    
    install_packages
    setup_fonts
    setup_configs
    
    # Reload Termux settings
    echo -e "${BLUE}Reloading Termux settings...${RESET}"
    termux-reload-settings 2>/dev/null || true
    
    setup_zsh_plugins
    setup_astronvim
    
    # Set default shell
    echo -e "${BOLD}Setting zsh as default shell...${RESET}"
    if chsh -s zsh 2>> "$ERROR_LOG"; then
        log_success "Default shell set to zsh"
    else
        log_warning "Could not set default shell (may need manual setup)"
    fi
    
    # Final summary
    echo -e "\n${BOLD}${GREEN}╔════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${GREEN}║     Installation Complete!            ║${RESET}"
    echo -e "${BOLD}${GREEN}╚════════════════════════════════════════╝${RESET}\n"
    
    echo -e "${CYAN}Next steps:${RESET}"
    echo -e "  1. ${YELLOW}Restart Termux${RESET} or run: ${BOLD}zsh${RESET}"
    echo -e "  2. Check errors (if any): ${BOLD}cat $ERROR_LOG${RESET}"
    echo -e "  3. Enjoy your new theme!\n"
    
    log_success "Installation completed successfully"
    echo "Finished: $(date)" >> "$ERROR_LOG"
}

# Run main function
main
