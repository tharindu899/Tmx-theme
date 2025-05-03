#!/bin/bash

# Configuration
ERROR_LOG="$HOME/skip_errors.log"
THEME_DIR=""
THEME_NAME=""
COLUMNS=$(tput cols)
OS_TYPE=""
PKG_MANAGER=""
INSTALL_CMD=""
PREFIX_PATH=""
ZSH_PLUGIN_PATH=""

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

# OS Selection
#!/bin/bash

# ... [Keep all previous configuration variables and functions unchanged] ...

# Modified OS Selection menu with Uninstall option
select_os() {
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
        echo -e "${CYAN}  ${BOLD}1) Termux (Android)${RESET}"
        echo -e "${CYAN}  ${BOLD}2) Ubuntu/Debian${RESET}"
        echo -e "${RED}  ${BOLD}3) Uninstall Theme${RESET}"
        echo -e "${YELLOW}  ${BOLD}4) Exit${RESET}"
        echo
        read -p "$(echo -e "${BOLD}${MAGENTA}Select option (1-4): ${RESET}")" choice

        case "$choice" in
            1)
                OS_TYPE="termux"
                PKG_MANAGER="pkg"
                INSTALL_CMD="install -y"
                PREFIX_PATH="$HOME/../usr"
                ZSH_PLUGIN_PATH="$PREFIX_PATH/etc/.plugin"
                return 0
                ;;
            2)
                OS_TYPE="ubuntu"
                PKG_MANAGER="sudo apt-get"
                INSTALL_CMD="install -y"
                PREFIX_PATH="/usr"
                ZSH_PLUGIN_PATH="$HOME/.oh-my-zsh/plugins"
                return 0
                ;;
            3) uninstall_theme; exit 0 ;;
            4) echo -e "${RED}Exiting...${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please enter 1-4.${RESET}"; sleep 1 ;;
        esac
    done
}


# ... [Rest of the script remains unchanged] ...
# Theme selection
select_theme() {
    while true; do
        clear
        echo -e "${ART_COLOR}"
        echo -e "${BOLD}Select Theme for ${OS_TYPE^}${RESET}"
        echo -e "${CYAN}  ${BOLD}1) Black Theme${RESET}"
        echo -e "${CYAN}  ${BOLD}2) Color Theme${RESET}"
        echo -e "${YELLOW}  ${BOLD}3) Back to OS Selection${RESET}"
        echo
        read -p "$(echo -e "${BOLD}${MAGENTA}Select theme (1-3): ${RESET}")" choice

        case "$choice" in
            1) THEME_DIR="black"; return 0 ;;
            2) THEME_DIR="color"; return 0 ;;
            3) return 1 ;;
            *) echo -e "${RED}Invalid option. Please enter 1-3.${RESET}"; sleep 1 ;;
        esac
    done
}

# Installation tasks
install_packages() {
    echo -e "\n${RED}${BOLD}••• Installation may take 10-20 minutes •••${RESET}"
    echo -e "${BOLD}---------------------------------------------${RESET}"

    # Common packages
    local common_packages=(
        zsh git wget curl python3 micro figlet lsd
        ripgrep ruby fd-find fzf lolcat
    )

    # OS-specific packages
    if [ "$OS_TYPE" == "termux" ]; then
        run_task "${YELLOW}Updating packages${RESET}" pkg update
        run_task "${YELLOW}Upgrading system${RESET}" pkg upgrade -y
        run_task "${BLUE}Installing core utilities${RESET}" \
            pkg install "${common_packages[@]}" ncurses-utils neovim -y
        run_task "${BLUE}Installing development tools${RESET}" \
            pkg install lua-language-server lazygit -y
        run_task "${BLUE}Installing Python packages${RESET}" \
            pip install neovim
        run_task "${BLUE}Installing Node packages${RESET}" \
            npm install -g neovim
        run_task "${BLUE}Installing Ruby gems${RESET}" \
            gem install neovim lolcat
    else
        run_task "${YELLOW}Updating packages${RESET}" sudo apt-get update
        run_task "${YELLOW}Upgrading system${RESET}" sudo apt-get upgrade -y
    fi
}

setup_fonts() {
    # Common font setup for both OS types
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ]; then
        if [ "$OS_TYPE" == "termux" ]; then
            mkdir -p ~/.termux
            run_task "${MAGENTA}Installing Termux font${RESET}" \
                cp -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" ~/.termux/font.ttf
        else
            run_task "${MAGENTA}Installing system font${RESET}" \
                sudo cp -f "$HOME/Tmx-theme/$THEME_DIR/font.ttf" /usr/share/fonts/truetype/
            run_task "${MAGENTA}Updating font cache${RESET}" \
                sudo fc-cache -f -v
        fi
    fi

    # ASCII art font setup
    if [ -f "$HOME/Tmx-theme/$THEME_DIR/ASCII.flf" ]; then
        if [ "$OS_TYPE" == "termux" ]; then
            run_task "${CYAN}Installing ASCII font${RESET}" \
                cp -f "$HOME/Tmx-theme/$THEME_DIR/ASCII.flf" $PREFIX/share/figlet/
        else
            run_task "${CYAN}Installing ASCII font${RESET}" \
                sudo cp -f "$HOME/Tmx-theme/$THEME_DIR/ASCII.flf" /usr/share/figlet/
        fi
    fi

    # Additional font types
    for font_ext in {ttf,otf,flf}; do
        if [ -f "$HOME/Tmx-theme/$THEME_DIR/font.${font_ext}" ]; then
            case $font_ext in
                ttf|otf)
                    if [ "$OS_TYPE" == "termux" ]; then
                        mkdir -p ~/.termux
                        run_task "${MAGENTA}Installing ${font_ext^^} font${RESET}" \
                            cp -f "$HOME/Tmx-theme/$THEME_DIR/font.${font_ext}" ~/.termux/
                    else
                        run_task "${MAGENTA}Installing ${font_ext^^} font${RESET}" \
                            sudo cp -f "$HOME/Tmx-theme/$THEME_DIR/font.${font_ext}" /usr/share/fonts/truetype/
                        run_task "${MAGENTA}Updating font cache${RESET}" \
                            sudo fc-cache -f -v
                    fi
                    ;;
                flf)
                    if [ "$OS_TYPE" == "termux" ]; then
                        run_task "${CYAN}Installing Figlet font${RESET}" \
                            cp -f "$HOME/Tmx-theme/$THEME_DIR/font.${font_ext}" $PREFIX/share/figlet/
                    else
                        run_task "${CYAN}Installing Figlet font${RESET}" \
                            sudo cp -f "$HOME/Tmx-theme/$THEME_DIR/font.${font_ext}" /usr/share/figlet/
                    fi
                    ;;
            esac
        fi
    done
}
# ... [Keep all previous configuration variables and functions unchanged] ...

setup_configs() {
    local config_files=(
        ".p10k.zsh"
        ".banner.sh"
        ".draw"
        ".draw.sh"
    )

    # Handle OS-specific .zshrc
    if [ "$OS_TYPE" == "ubuntu" ]; then
        # Ubuntu-specific zshrc (using .zshrc1 in theme directory)
        run_task "${BLUE}Configuring .zshrc${RESET}" \
            cp -f "$HOME/Tmx-theme/$THEME_DIR/.zshrc1" "$HOME/.zshrc"
        config_files+=(
            "../etc/zsh/zshrc"
        )
    else
        # Termux standard configuration
        config_files+=(
            ".zshrc"
            ".termux/termux.properties"
            ".termux/colors.properties"
            "../usr/etc/zshrc"
        )
    fi

    # Copy remaining config files
    for file in "${config_files[@]}"; do
        local target_file="$HOME/${file//..\/usr/$PREFIX_PATH}"
        run_task "${BLUE}Configuring ${target_file}${RESET}" \
            cp -f "$HOME/Tmx-theme/$THEME_DIR/${file##*/}" "$target_file"
    done
}

# ... [Rest of the script remains unchanged] ...

setup_zsh_plugins() {
    # Install Oh My Zsh
    if [ ! -d ~/.oh-my-zsh/.git ]; then
        run_task "${CYAN}Installing Oh My Zsh${RESET}" \
            git clone --depth 1 "https://github.com/ohmyzsh/ohmyzsh.git" ~/.oh-my-zsh
    fi

    # Create required directories
    mkdir -p ~/.oh-my-zsh/{plugins,custom/themes}
    mkdir -p "$ZSH_PLUGIN_PATH"

    # Install Powerlevel10k
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        run_task "${CYAN}Installing Powerlevel10k${RESET}" \
            git clone --depth 1 "https://github.com/romkatv/powerlevel10k.git" \
            ~/.oh-my-zsh/custom/themes/powerlevel10k
    fi

    # Plugin repositories
    local plugins=(
        "zsh-users/zsh-completions"
        "zsh-users/zsh-history-substring-search"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "bobthecow/git-flow-completion"
    )

    # Install plugins
    for plugin in "${plugins[@]}"; do
        local name=${plugin##*/}
        local target_dir="$ZSH_PLUGIN_PATH/$name"
        [ -d "$target_dir" ] || run_task "${CYAN}Installing ${name}${RESET}" \
            git clone --depth 1 "https://github.com/$plugin" "$target_dir"
    done
}

uninstall_theme() {
    echo -e "\n${RED}${BOLD}!!! Uninstalling Tmx Theme !!!${RESET}"
    
    # Configuration files to remove
    local config_files=(
        # User-specific files
        "$HOME/.zshrc"
        "$HOME/.p10k.zsh"
        "$HOME/.banner.sh"
        "$HOME/.draw"
        "$HOME/.draw.sh"
        "$HOME/skip_errors.log"
        
        # System-wide zsh configuration
        "/etc/zsh/zshrc"
        
        # Cache files
        "$HOME/.cache/p10k-instant-prompt-${USER}.zsh"
        
        # Termux-specific (safe to include)
        "$HOME/.termux"
        "$HOME/../usr/etc/zshrc"
    )

    # Remove files/directories
    for file in "${config_files[@]}"; do
        if [ -e "$file" ]; then
            run_task "${RED}Removing ${file}${RESET}" rm -rf "$file"
        fi
    done

    # Remove Oh My Zsh
    [ -d "$HOME/.oh-my-zsh" ] && \
        run_task "${RED}Removing Oh My Zsh${RESET}" rm -rf "$HOME/.oh-my-zsh"

    # Remove nvim config (if exists)
    [ -d "$HOME/.config/nvim" ] && \
        run_task "${RED}Removing Neovim config${RESET}" rm -rf "$HOME/.config/nvim"

    # Reset shell to default if changed
    current_shell=$(basename "$SHELL")
    if [ "$current_shell" = "zsh" ]; then
        echo -e "${YELLOW}Resetting default shell to bash...${RESET}"
        run_task "${YELLOW}Changing default shell${RESET}" chsh -s "$(which bash)"
    fi

    # Final message
    echo -e "\n${GREEN}${BOLD}✓ Theme uninstalled completely!${RESET}"
    echo -e "${YELLOW}Note: Installed packages (zsh, lsd, etc.) were not removed.${RESET}"
    echo -e "${YELLOW}To remove packages: ${BOLD}sudo apt remove zsh lsd bat${RESET}"
}

# Main execution
while true; do
    select_os && while select_theme; do
        install_packages
        setup_fonts
        setup_configs
        setup_zsh_plugins
        
        if [ "$OS_TYPE" == "termux" ]; then
            termux-reload-settings
            run_task "${GREEN}Installing AstroNvim${RESET}" \
                git clone --depth 1 "https://github.com/tharindu899/Astronvim-Termux.git" ~/.config/nvim
        fi

        run_task "${BOLD}Setting default shell${RESET}" chsh -s $(which zsh)
        echo -e "\n${BOLD}${GREEN}✓ Setup complete! Restart your terminal or run 'zsh'.${RESET}"
        exit 0
    done
done
