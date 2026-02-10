#!/bin/bash

#############################################
# Tmx-Theme Installer v3.0
# Modern Termux/Ubuntu Theme Installation
#############################################

set -e  # Exit on error

# === CONFIGURATION ===
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_DIR="$HOME"
readonly LOG_FILE="$HOME_DIR/tmx-install.log"
readonly BACKUP_DIR="$HOME_DIR/.tmx-backup-$(date +%Y%m%d-%H%M%S)"

# === COLORS ===
readonly C_RED='\033[0;31m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[1;33m'
readonly C_BLUE='\033[0;34m'
readonly C_MAGENTA='\033[0;35m'
readonly C_CYAN='\033[0;36m'
readonly C_BOLD='\033[1m'
readonly C_RESET='\033[0m'

# === UTILITY FUNCTIONS ===

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${C_RED}✗ ERROR: $*${C_RESET}" >&2
    log "ERROR: $*"
    exit 1
}

success() {
    echo -e "${C_GREEN}✓ $*${C_RESET}"
    log "SUCCESS: $*"
}

info() {
    echo -e "${C_CYAN}ℹ $*${C_RESET}"
    log "INFO: $*"
}

warn() {
    echo -e "${C_YELLOW}⚠ $*${C_RESET}"
    log "WARNING: $*"
}

spinner() {
    local pid=$1
    local msg="$2"
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    
    while kill -0 "$pid" 2>/dev/null; do
        for char in "${spin[@]}"; do
            printf "\r${C_MAGENTA}[%s]${C_RESET} %s" "$char" "$msg"
            sleep 0.1
        done
    done
    wait "$pid"
    local exit_code=$?
    printf "\r"
    return $exit_code
}

run_task() {
    local description="$1"
    shift
    
    log "Running: $description"
    ("$@") >> "$LOG_FILE" 2>&1 &
    local pid=$!
    
    if spinner "$pid" "$description"; then
        success "$description"
        return 0
    else
        error "$description failed (check $LOG_FILE)"
        return 1
    fi
}

confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    if [[ "$default" == "y" ]]; then
        read -p "$(echo -e "${C_YELLOW}$prompt [Y/n]: ${C_RESET}")" response
        response=${response:-y}
    else
        read -p "$(echo -e "${C_YELLOW}$prompt [y/N]: ${C_RESET}")" response
        response=${response:-n}
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

show_header() {
    clear
    echo -e "${C_CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════╗
║                                                      ║
║     ████████╗███╗   ███╗██╗  ██╗                    ║
║     ╚══██╔══╝████╗ ████║╚██╗██╔╝                    ║
║        ██║   ██╔████╔██║ ╚███╔╝                     ║
║        ██║   ██║╚██╔╝██║ ██╔██╗                     ║
║        ██║   ██║ ╚═╝ ██║██╔╝ ██╗                    ║
║        ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝                    ║
║                                                      ║
║           Terminal Theme Installer v3.0             ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${C_RESET}\n"
}

# === DETECTION ===

detect_os() {
    if [[ -d "/data/data/com.termux" ]]; then
        echo "termux"
    elif [[ -f "/etc/debian_version" ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

check_requirements() {
    local os_type=$(detect_os)
    
    info "Detected OS: ${C_BOLD}${os_type}${C_RESET}"
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        error "No internet connection detected"
    fi
    
    # Check if running as root (Ubuntu)
    if [[ "$os_type" == "ubuntu" ]] && [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root. It will ask for sudo when needed."
    fi
    
    echo "$os_type"
}

# === MENU SYSTEM ===

show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo -e "${C_BOLD}${title}${C_RESET}\n"
    
    local i=1
    for option in "${options[@]}"; do
        echo -e "  ${C_CYAN}${i})${C_RESET} $option"
        ((i++))
    done
    echo ""
}

get_choice() {
    local max=$1
    local choice
    
    while true; do
        read -p "$(echo -e "${C_MAGENTA}Select option (1-${max}): ${C_RESET}")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= max)); then
            echo "$choice"
            return 0
        fi
        warn "Invalid choice. Please enter a number between 1 and $max"
    done
}

# === THEME SELECTION ===

select_theme() {
    show_header
    show_menu "Choose Your Theme:" \
        "🌑 Dark Theme (Black background)" \
        "🌈 Colorful Theme (Vibrant colors)" \
        "🔙 Back to main menu"
    
    case $(get_choice 3) in
        1) echo "black" ;;
        2) echo "color" ;;
        3) return 1 ;;
    esac
}

# === INSTALLATION ===

create_backup() {
    local files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.p10k.zsh"
        "$HOME/.termux"
        "$HOME/.config/nvim"
    )
    
    info "Creating backup at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    for file in "${files_to_backup[@]}"; do
        if [[ -e "$file" ]]; then
            cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    success "Backup created successfully"
}

install_packages_termux() {
    info "Installing packages for Termux..."
    
    # Update repos
    run_task "Updating package lists" pkg update -y
    
    # Essential packages
    local packages=(
        zsh git wget curl
        python nodejs ruby
        neovim ripgrep fzf
        figlet lolcat
    )
    
    run_task "Installing essential packages" pkg install -y "${packages[@]}"
    
    # Optional packages (don't fail if unavailable)
    pkg install -y lsd logo-ls lazygit lua-language-server 2>/dev/null || true
    
    # Language-specific packages
    pip install --break-system-packages neovim 2>/dev/null || true
    npm install -g neovim 2>/dev/null || true
    gem install neovim lolcat 2>/dev/null || true
}

install_packages_ubuntu() {
    info "Installing packages for Ubuntu..."
    
    # Update repos
    run_task "Updating package lists" sudo apt-get update
    
    # Essential packages
    local packages=(
        zsh git wget curl
        python3 python3-pip nodejs npm ruby
        neovim ripgrep fzf
        figlet fonts-powerline
    )
    
    run_task "Installing essential packages" sudo apt-get install -y "${packages[@]}"
    
    # Optional packages
    sudo apt-get install -y fd-find bat 2>/dev/null || true
    
    # Ruby gems
    gem install lolcat 2>/dev/null || true
}

setup_zsh_framework() {
    info "Setting up Zsh framework..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        run_task "Installing Oh My Zsh" \
            git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
    
    # Install Powerlevel10k
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        run_task "Installing Powerlevel10k theme" \
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi
    
    # Install plugins
    local plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin##*/}"
        local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
        
        if [[ ! -d "$plugin_dir" ]]; then
            run_task "Installing plugin: $plugin_name" \
                git clone --depth=1 "https://github.com/$plugin" "$plugin_dir"
        fi
    done
}

install_theme_files() {
    local theme="$1"
    local os_type="$2"
    
    info "Installing theme files: $theme"
    
    # Copy theme configurations
    local theme_dir="$SCRIPT_DIR/$theme"
    
    if [[ ! -d "$theme_dir" ]]; then
        error "Theme directory not found: $theme_dir"
    fi
    
    # Copy Zsh configs
    cp "$theme_dir/.zshrc" "$HOME/.zshrc"
    cp "$theme_dir/.p10k.zsh" "$HOME/.p10k.zsh"
    cp "$theme_dir/.banner.sh" "$HOME/.banner.sh"
    chmod +x "$HOME/.banner.sh"
    
    # Copy ASCII art files
    [[ -f "$theme_dir/.draw" ]] && cp "$theme_dir/.draw" "$HOME/.draw"
    [[ -f "$theme_dir/.draw.sh" ]] && cp "$theme_dir/.draw.sh" "$HOME/.draw.sh"
    [[ -f "$theme_dir/ASCII-Shadow.flf" ]] && \
        sudo cp "$theme_dir/ASCII-Shadow.flf" /usr/share/figlet/ 2>/dev/null || \
        cp "$theme_dir/ASCII-Shadow.flf" "$PREFIX/share/figlet/" 2>/dev/null || true
    
    # Termux-specific files
    if [[ "$os_type" == "termux" ]]; then
        mkdir -p "$HOME/.termux"
        cp "$theme_dir/termux.properties" "$HOME/.termux/"
        cp "$theme_dir/colors.properties" "$HOME/.termux/"
        [[ -f "$theme_dir/font.ttf" ]] && cp "$theme_dir/font.ttf" "$HOME/.termux/"
    fi
    
    success "Theme files installed"
}

set_default_shell() {
    info "Setting Zsh as default shell..."
    
    local zsh_path=$(which zsh)
    
    if [[ "$SHELL" != "$zsh_path" ]]; then
        chsh -s "$zsh_path" || sudo chsh -s "$zsh_path" "$USER"
        success "Default shell changed to Zsh"
    else
        info "Zsh is already the default shell"
    fi
}

# === UNINSTALL ===

uninstall_theme() {
    show_header
    warn "This will remove all Tmx-Theme configurations"
    
    if ! confirm "Are you sure you want to uninstall?"; then
        return 0
    fi
    
    info "Uninstalling Tmx-Theme..."
    
    # Remove config files
    rm -rf "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.banner.sh" \
           "$HOME/.draw" "$HOME/.draw.sh" "$HOME/.termux" \
           "$HOME/.oh-my-zsh" "$HOME/.config/nvim"
    
    # Reset shell
    if [[ "$SHELL" == "$(which zsh)" ]]; then
        chsh -s "$(which bash)" || sudo chsh -s "$(which bash)" "$USER"
    fi
    
    success "Tmx-Theme uninstalled successfully"
    info "Installed packages were not removed. Uninstall manually if needed."
}

# === MAIN MENU ===

main_menu() {
    while true; do
        show_header
        show_menu "Main Menu:" \
            "🚀 Install Theme" \
            "🗑️  Uninstall Theme" \
            "📋 View Installation Log" \
            "❌ Exit"
        
        case $(get_choice 4) in
            1) install_workflow ;;
            2) uninstall_theme; confirm "Press Enter to continue..."; ;;
            3) less "$LOG_FILE" ;;
            4) echo -e "\n${C_GREEN}Thank you for using Tmx-Theme!${C_RESET}\n"; exit 0 ;;
        esac
    done
}

install_workflow() {
    show_header
    
    # Detect OS
    local os_type=$(check_requirements)
    
    if [[ "$os_type" == "unknown" ]]; then
        error "Unsupported operating system"
    fi
    
    # Select theme
    local theme=$(select_theme)
    [[ -z "$theme" ]] && return 0
    
    # Confirm installation
    show_header
    info "OS Type: ${C_BOLD}$os_type${C_RESET}"
    info "Theme: ${C_BOLD}$theme${C_RESET}"
    echo ""
    
    if ! confirm "Proceed with installation?" "y"; then
        return 0
    fi
    
    # Create backup
    create_backup
    
    # Install packages
    if [[ "$os_type" == "termux" ]]; then
        install_packages_termux
    else
        install_packages_ubuntu
    fi
    
    # Setup Zsh
    setup_zsh_framework
    
    # Install theme
    install_theme_files "$theme" "$os_type"
    
    # Set default shell
    set_default_shell
    
    # Reload Termux settings
    [[ "$os_type" == "termux" ]] && termux-reload-settings 2>/dev/null || true
    
    # Success message
    echo ""
    success "Installation completed successfully!"
    echo ""
    echo -e "${C_YELLOW}Next steps:${C_RESET}"
    echo -e "  1. ${C_CYAN}Restart your terminal${C_RESET}"
    echo -e "  2. ${C_CYAN}Or run: source ~/.zshrc${C_RESET}"
    echo ""
    echo -e "${C_BLUE}Backup location: ${C_BOLD}$BACKUP_DIR${C_RESET}"
    echo -e "${C_BLUE}Installation log: ${C_BOLD}$LOG_FILE${C_RESET}"
    echo ""
    
    confirm "Press Enter to continue..."
}

# === ENTRY POINT ===

main() {
    # Initialize log
    echo "=== Tmx-Theme Installation Started ===" > "$LOG_FILE"
    log "Script directory: $SCRIPT_DIR"
    
    # Check if running in correct directory
    if [[ ! -f "$SCRIPT_DIR/black/.zshrc" ]] && [[ ! -f "$SCRIPT_DIR/color/.zshrc" ]]; then
        error "Theme files not found. Please run this script from the Tmx-theme directory."
    fi
    
    # Run main menu
    main_menu
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
