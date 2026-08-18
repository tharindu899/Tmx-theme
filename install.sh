#!/bin/bash

# ─────────────────────────────────────────────
#   TMX-THEME INSTALLER  v2.1
#   Real-time progress • Elapsed time • Size
# ─────────────────────────────────────────────

ERROR_LOG="$HOME/skip_errors.log"
THEME_DIR=""
COLUMNS=$(tput cols 2>/dev/null || echo 80)
MAX_RETRIES=3

# ── Colors ──────────────────────────────────
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
MAGENTA=$'\033[0;35m'
CYAN=$'\033[0;36m'
WHITE=$'\033[1;37m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# ── Cursor control ───────────────────────────
cursor_hide() { tput civis 2>/dev/null; }
cursor_show() { tput cnorm 2>/dev/null; }
trap 'cursor_show; echo -e "\n${RED}Interrupted.${RESET}"; exit 1' INT TERM

# ── Logging ──────────────────────────────────
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

# ── Format helpers ───────────────────────────
fmt_time() {
    local s=$1
    if (( s < 60 )); then
        printf "%ds" "$s"
    else
        printf "%dm%02ds" "$((s/60))" "$((s%60))"
    fi
}

fmt_size() {
    local bytes=$1
    if (( bytes < 1024 )); then
        printf "%dB" "$bytes"
    elif (( bytes < 1048576 )); then
        printf "%.1fKB" "$(echo "scale=1; $bytes/1024" | bc 2>/dev/null || echo 0)"
    else
        printf "%.1fMB" "$(echo "scale=1; $bytes/1048576" | bc 2>/dev/null || echo 0)"
    fi
}

# ── Get downloaded size from apt/pip/gem log ─
get_dl_size() {
    local logfile="$1"
    # Parse sizes from apt output: "Get:N ... [X kB]"
    local kb
    kb=$(grep -oP '\[\K[0-9.]+ [kMG]?B(?=\])' "$logfile" 2>/dev/null | awk '
        {
            val=$1; unit=$2
            if (unit=="kB" || unit=="KB") sum+=val*1024
            else if (unit=="MB")          sum+=val*1048576
            else if (unit=="GB")          sum+=val*1073741824
            else                          sum+=val
        }
        END { printf "%.0f", sum }
    ')
    echo "${kb:-0}"
}

# ── Spinner frames ───────────────────────────
SPIN_FRAMES=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

# ── run_task: run a command with live spinner + timer + size ──
# Usage: run_task "Label" [--dl] cmd [args...]
run_task() {
    local track_dl=0
    if [[ "$1" == "--dl" ]]; then track_dl=1; shift; fi
    local label="$1"; shift

    local tmpout
    tmpout=$(mktemp)
    local start_time
    start_time=$(date +%s)
    local frame_idx=0

    cursor_hide

    # Run command in background, redirect all output to tmp
    "$@" >"$tmpout" 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local now elapsed spin dl_info=""
        now=$(date +%s)
        elapsed=$(( now - start_time ))

        spin="${SPIN_FRAMES[$((frame_idx % ${#SPIN_FRAMES[@]}))]}"
        (( frame_idx++ ))

        if (( track_dl )); then
            local bytes
            bytes=$(get_dl_size "$tmpout")
            if (( bytes > 0 )); then
                dl_info=" ${DIM}↓$(fmt_size "$bytes")${RESET}"
            fi
        fi

        # Build the line
        local time_str elapsed_str
        elapsed_str=$(fmt_time "$elapsed")
        time_str="${DIM}[${elapsed_str}]${RESET}"

        # Truncate label if too long
        local max_label=$(( COLUMNS - 28 ))
        local short_label="${label:0:$max_label}"

        printf "\r  ${MAGENTA}%s${RESET} ${WHITE}%-*s${RESET} %s%s " \
            "$spin" "$max_label" "$short_label" "$time_str" "$dl_info"

        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?
    local end_time elapsed_total
    end_time=$(date +%s)
    elapsed_total=$(( end_time - start_time ))

    local time_str
    time_str=$(fmt_time "$elapsed_total")

    local dl_summary=""
    if (( track_dl )); then
        local bytes
        bytes=$(get_dl_size "$tmpout")
        if (( bytes > 0 )); then
            dl_summary=" ${CYAN}↓$(fmt_size "$bytes")${RESET}"
        fi
    fi

    if (( exit_code == 0 )); then
        printf "\r  ${GREEN}✔${RESET} ${WHITE}%-*s${RESET} ${DIM}[%s]${RESET}%s\n" \
            "$(( COLUMNS - 20 ))" "$label" "$time_str" "$dl_summary"
    else
        printf "\r  ${RED}✘${RESET} ${WHITE}%-*s${RESET} ${DIM}[%s]${RESET}%s\n" \
            "$(( COLUMNS - 20 ))" "$label" "$time_str" "$dl_summary"
        log_error "Task failed: $label"
        cat "$tmpout" >> "$ERROR_LOG"
    fi

    rm -f "$tmpout"
    cursor_show
    return "$exit_code"
}

# ── Section header ───────────────────────────
section() {
    local title="$1"
    local pad=$(( (COLUMNS - ${#title} - 4) / 2 ))
    local line
    line=$(printf '─%.0s' $(seq 1 $((COLUMNS-2))))
    echo -e "\n${DIM}┌${line}┐${RESET}"
    printf "${DIM}│${RESET}%*s${BOLD}${CYAN} %s ${RESET}%*s${DIM}│${RESET}\n" \
        "$pad" "" "$title" "$pad" ""
    echo -e "${DIM}└${line}┘${RESET}\n"
}

# ── Network check ────────────────────────────
check_network() {
    section "NETWORK CHECK"
    printf "  ${CYAN}⟳${RESET} Checking connectivity..."
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        echo -e "\r  ${GREEN}✔${RESET} Network connection ${GREEN}OK${RESET}"
    else
        echo -e "\r  ${RED}✘${RESET} ${RED}No internet connection. Please reconnect and retry.${RESET}"
        exit 1
    fi
}

# ── Fix repos ────────────────────────────────
fix_termux_repos() {
    [ -f "$PREFIX/etc/apt/sources.list" ] && \
        cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.backup"
    cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
deb https://packages.termux.dev/apt/termux-main stable main
EOF
    run_task --dl "Updating repository index" apt update
}

# ── Theme selector ───────────────────────────
select_theme() {
    local github_flag=1   # local copy

    while true; do
        clear
        echo -e "${MAGENTA}"
        cat << "EOF"
  ████████╗██╗  ██╗███████╗███╗   ███╗███████╗
  ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝
     ██║   ███████║█████╗  ██╔████╔██║█████╗
     ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝
     ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗
     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝
EOF
        echo -e "${RESET}"

        local line
        line=$(printf '─%.0s' $(seq 1 $((COLUMNS-2))))
        echo -e "${DIM}${line}${RESET}"
        echo -e "  ${BOLD}${CYAN}1)${RESET}  🖤  Black Theme"
        echo -e "  ${BOLD}${CYAN}2)${RESET}  🎨  Color Theme"
        echo -e "  ${BOLD}${RED}3)${RESET}  🗑️   Uninstall"

        # GitHub toggle with current status
        local status="[ON]"; (( github_flag == 0 )) && status="[OFF]"
        echo -e "  ${BOLD}${YELLOW}4)${RESET}  🔄  GitHub dual accounts  ${CYAN}${status}${RESET}"

        echo -e "  ${BOLD}${YELLOW}5)${RESET}  ✕   Exit"
        echo -e "${DIM}${line}${RESET}"
        echo
        read -rp "$(echo -e "  ${BOLD}${MAGENTA}Select option [1-5]: ${RESET}")" choice

        case "$choice" in
            1) THEME_DIR="black"
               SETUP_GITHUB=$github_flag
               return 0 ;;
            2) THEME_DIR="color"
               SETUP_GITHUB=$github_flag
               return 0 ;;
            3) uninstall_theme; exit 0 ;;
            4) (( github_flag == 1 )) && github_flag=0 || github_flag=1 ;;
            5) echo -e "\n${YELLOW}Bye!${RESET}"; exit 0 ;;
            *) echo -e "  ${RED}Invalid choice. Enter 1–5.${RESET}"; sleep 1 ;;
        esac
    done
}

# ── Install packages ─────────────────────────
install_packages() {
    section "PACKAGE INSTALLATION"
    echo -e "  ${YELLOW}⚠${RESET}  This step may take ${BOLD}10–20 minutes${RESET} depending on your connection.\n"

    fix_termux_repos

    run_task             "Upgrading system packages"        apt upgrade -y
    run_task --dl        "Core utilities (zsh git python figlet lsd)" \
        pkg install zsh git wget curl python figlet lsd logo-ls ncurses-utils -y
    run_task --dl        "Dev tools (neovim lua ripgrep lazygit)" \
        pkg install neovim lua-language-server ripgrep lazygit -y
    run_task --dl        "Ruby + figlet (for lolcat)" \
        pkg install figlet ruby -y
    run_task --dl        "Build tools & extras" \
        apt install build-essential zip termux-api gdu gdb gdbserver gh fd fzf \
        neovim lua-language-server jq-lsp luarocks stylua ripgrep yarn \
        python-pip ccls clang zig rust-analyzer -y
    run_task             "pip: neovim"           pip install neovim
    run_task --dl        "npm: neovim"           npm install -g neovim
    run_task             "gem: neovim"           gem install neovim
    run_task             "gem: lolcat"           gem install lolcat
}

# ── Font setup ───────────────────────────────
setup_fonts() {
    section "FONTS & CONFIG"
    mkdir -p ~/.termux
    run_task "Installing Nerd Font" \
        cp -f "$HOME/Tmx-theme/src/font.ttf" ~/.termux/
    if [ -f "$HOME/Tmx-theme/src/ASCII-Shadow.flf" ]; then
        run_task "Installing figlet font (ASCII-Shadow)" \
            cp -f "$HOME/Tmx-theme/src/ASCII-Shadow.flf" "$PREFIX/share/figlet/"
    fi
}

# ── Theme config ─────────────────────────────
setup_color() {
    run_task "Applying theme config (.p10k.zsh)" \
        cp -f "$HOME/Tmx-theme/$THEME_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
}

# ── Dot-files ────────────────────────────────
setup_configs() {
    local -A files=(
        [".termux/termux.properties"]="termux.properties"
        [".termux/colors.properties"]="colors.properties"
        [".termux/font.ttf"]="font.ttf"
        [".zshrc"]=".zshrc"
        [".banner.sh"]=".banner.sh"
        [".draw"]=".draw"
        [".draw.sh"]=".draw.sh"
        ["../usr/etc/zshrc"]="zshrc"
    )

    for dest in "${!files[@]}"; do
        local src="${files[$dest]}"
        run_task "Config → ~/${dest##*/}" \
            cp -f "$HOME/Tmx-theme/src/$src" "$HOME/$dest"
    done
}

# ── GitHub dual account setup ──────────────────
setup_github_accounts() {
    section "GITHUB DUAL ACCOUNTS"

    local script="$HOME/Tmx-theme/scripts/github-dual-account.sh"

    if [ ! -f "$script" ]; then
        echo -e " ${RED}✘${RESET} GitHub account setup script not found."
        log_error "Missing GitHub dual account script: $script"
        return 1
    fi

    run_task "Configuring GitHub accounts" \
        bash "$script"
}

# ── ZSH plugins ──────────────────────────────
setup_zsh_plugins() {
    section "ZSH PLUGINS"

    if [ ! -d ~/.oh-my-zsh/.git ]; then
        run_task --dl "Installing Oh My Zsh" \
            git clone --depth 1 "https://github.com/ohmyzsh/ohmyzsh.git" ~/.oh-my-zsh
    else
        echo -e "  ${DIM}✔ Oh My Zsh already installed — skipping${RESET}"
    fi

    mkdir -p ~/.oh-my-zsh/{plugins,custom/themes}
    mkdir -p "$PREFIX/etc/.plugin"

    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        run_task --dl "Installing Powerlevel10k theme" \
            git clone --depth 1 "https://github.com/romkatv/powerlevel10k.git" \
            ~/.oh-my-zsh/custom/themes/powerlevel10k
    else
        echo -e "  ${DIM}✔ Powerlevel10k already installed — skipping${RESET}"
    fi

    local -a ohmyzsh_plugins=(
        "zsh-users/zsh-completions"
        "zsh-users/zsh-history-substring-search"
        "bobthecow/git-flow-completion"
    )
    local -a etc_plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
    )

    for plugin in "${ohmyzsh_plugins[@]}"; do
        local name="${plugin##*/}"
        local target="$HOME/.oh-my-zsh/plugins/$name"
        if [ ! -d "$target" ]; then
            run_task --dl "Plugin: $name" \
                git clone --depth 1 "https://github.com/$plugin" "$target"
        else
            echo -e "  ${DIM}✔ $name already present — skipping${RESET}"
        fi
    done

    for plugin in "${etc_plugins[@]}"; do
        local name="${plugin##*/}"
        local target="$PREFIX/etc/.plugin/$name"
        if [ ! -d "$target" ]; then
            run_task --dl "Plugin: $name" \
                git clone --depth 1 "https://github.com/$plugin" "$target"
        else
            echo -e "  ${DIM}✔ $name already present — skipping${RESET}"
        fi
    done
}

# ── AstroNvim ────────────────────────────────
setup_astronvim() {
    section "NEOVIM (ASTRONVIM)"
    [ -d ~/.config/nvim ] && run_task "Removing old nvim config" rm -rf ~/.config/nvim
    run_task --dl "Cloning AstroNvim config" \
        git clone --depth 1 "https://github.com/tharindu899/tmx-nvim.git" ~/.config/nvim
}

# ── Uninstall ────────────────────────────────
uninstall_theme() {
    section "UNINSTALL"
    run_task "Removing theme files" \
        rm -rf ~/.termux ~/.zshrc ~/.p10k.zsh ~/.banner.sh ~/.oh-my-zsh ~/.config/nvim
    termux-reload-settings
    echo -e "\n  ${GREEN}✔${RESET} Theme uninstalled successfully.\n"
}

# ── Summary ──────────────────────────────────
print_summary() {
    local line
    line=$(printf '─%.0s' $(seq 1 $((COLUMNS-2))))
    echo
    echo -e "${DIM}${line}${RESET}"
    echo -e "  ${GREEN}${BOLD}✔  Setup complete!${RESET}"
    echo -e "  ${DIM}Restart Termux or run:${RESET}  ${CYAN}zsh${RESET}"
    echo -e "${DIM}${line}${RESET}"
    echo
}

# ════════════════════════════════════════════
#   MAIN
# ════════════════════════════════════════════
check_network
select_theme

clear
echo -e "\n  ${BOLD}${MAGENTA}Theme:${RESET} ${BOLD}${CYAN}${THEME_DIR^}${RESET}\n"

install_packages
setup_fonts
setup_color
setup_configs

run_task "Reloading Termux settings" termux-reload-settings

setup_zsh_plugins

# Conditionally run GitHub setup
if (( SETUP_GITHUB )); then
    setup_github_accounts
else
    echo -e "  ${DIM}⏭  GitHub dual‑account setup skipped by user.${RESET}"
fi

setup_astronvim

section "FINALIZING"
run_task "Setting default shell to zsh" chsh -s zsh

print_summary