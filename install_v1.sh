#!/bin/bash

# ═══════════════════════════════════════════════════════════
#   TMX-THEME INSTALLER  v4.0
#   Single persistent log box  ·  tput layout  ·  progress
# ═══════════════════════════════════════════════════════════

ERROR_LOG="$HOME/skip_errors.log"
THEME_DIR=""

# ── Terminal size ─────────────────────────────────────────
COLS=$(tput cols  2>/dev/null || echo 80)
LINES=$(tput lines 2>/dev/null || echo 24)

_refresh_dims() {
    COLS=$(tput cols  2>/dev/null || echo 80)
    LINES=$(tput lines 2>/dev/null || echo 24)
    PANEL_W=$(( COLS - 2 ))
    PANEL_ROW=$(( LINES - PANEL_H ))
    LOG_MAX_ROWS=$(( PANEL_ROW - LOG_TOP - 1 ))
}
trap '_refresh_dims; _redraw_all' WINCH

# ── tput helpers ──────────────────────────────────────────
_cup()  { tput cup  "$1" "$2" 2>/dev/null; }
_el()   { tput el          2>/dev/null; }
_civis(){ tput civis       2>/dev/null; }
_cnorm(){ tput cnorm       2>/dev/null; }
_sc()   { tput sc          2>/dev/null; }
_rc()   { tput rc          2>/dev/null; }

# ── Colors ────────────────────────────────────────────────
R=$'\033[0;31m'    G=$'\033[0;32m'    Y=$'\033[1;33m'
B=$'\033[0;34m'    M=$'\033[0;35m'    C=$'\033[0;36m'
W=$'\033[1;37m'    DIM=$'\033[2m'     BOLD=$'\033[1m'
RST=$'\033[0m'

# ── Exit / abort ──────────────────────────────────────────
_abort() {
    _cnorm
    tput rmcup 2>/dev/null
    echo -e "\n${R}Interrupted.${RST}"
    exit 1
}
trap '_abort' INT TERM

# ═══════════════════════════════════════════════════════════
#   LAYOUT  (computed once, static for entire install)
# ═══════════════════════════════════════════════════════════
PANEL_H=8          # bottom status panel height
PANEL_ROW=0        # = LINES - PANEL_H
PANEL_W=0          # = COLS  - 2
LOG_TOP=3          # first log row inside top box (row 0=border, 1=subtitle, 2=divider)
LOG_COL=3          # left margin inside box
LOG_MAX_ROWS=0     # computed by _refresh_dims

# ── Draw top log box ──────────────────────────────────────
_draw_log_box() {
    local r=0 c=1
    local h="$PANEL_ROW"
    local w="$PANEL_W"
    local inner=$(( w - 2 ))

    # top border with title
    _cup "$r" "$c"
    local title=" TMX-THEME INSTALLER "
    local tl=${#title}
    local lp=$(( (inner - tl) / 2 ))
    local rp=$(( inner - tl - lp ))
    printf "${DIM}╔${RST}"
    printf '═%.0s' $(seq 1 "$lp")
    printf "${BOLD}${C}%s${RST}" "$title"
    printf "${DIM}"
    printf '═%.0s' $(seq 1 "$rp")
    printf "╗${RST}"

    # subtitle row (row 1)
    _cup 1 "$c"
    printf "${DIM}║${RST}  ${DIM}%-$(( inner-2 ))s${DIM}║${RST}" \
        "All tasks · live log  $(date +'%Y-%m-%d  %H:%M')"

    # divider (row 2)
    _cup 2 "$c"
    printf "${DIM}╠"
    printf '─%.0s' $(seq 1 "$inner")
    printf "╣${RST}"

    # side bars for log rows
    for (( row=LOG_TOP; row<h-1; row++ )); do
        _cup "$row" "$c";           printf "${DIM}║${RST}"
        _cup "$row" $(( c+w-1 ));   printf "${DIM}║${RST}"
    done

    # bottom border
    _cup $(( h-1 )) "$c"
    printf "${DIM}╚"
    printf '═%.0s' $(seq 1 "$inner")
    printf "╝${RST}"
}

# ── Draw bottom status panel ──────────────────────────────
_draw_panel_box() {
    local r="$PANEL_ROW" c=1 w="$PANEL_W"
    local inner=$(( w - 2 ))
    local title=" PROGRESS "
    local tl=${#title}
    local lp=$(( (inner - tl) / 2 ))
    local rp=$(( inner - tl - lp ))

    _cup "$r" "$c"
    printf "${DIM}╠${RST}"
    printf '═%.0s' $(seq 1 "$lp")
    printf "${BOLD}${Y}%s${RST}${DIM}" "$title"
    printf '═%.0s' $(seq 1 "$rp")
    printf "╣${RST}"

    for (( i=1; i<PANEL_H-1; i++ )); do
        _cup $(( r+i )) "$c";              printf "${DIM}║${RST}"
        _cup $(( r+i )) $(( c+w-1 ));     printf "${DIM}║${RST}"
    done

    _cup $(( r+PANEL_H-1 )) "$c"
    printf "${DIM}╚"
    printf '═%.0s' $(seq 1 "$inner")
    printf "╝${RST}"
}

# ── Full frame init (called once at startup) ──────────────
_init_ui() {
    _refresh_dims
    tput smcup 2>/dev/null
    tput clear 2>/dev/null
    _draw_log_box
    _draw_panel_box
}

# ── Redraw on resize ──────────────────────────────────────
_redraw_all() {
    tput clear 2>/dev/null
    _draw_log_box
    _draw_panel_box
    _repaint_log
    _update_panel "$_LAST_LABEL" "$_LAST_ELAPSED" "$_LAST_DL" "$_LAST_PCT"
}

# ═══════════════════════════════════════════════════════════
#   SCROLLING LOG  (persists across all sections)
# ═══════════════════════════════════════════════════════════
declare -a _LOG_BUF=()   # stores all lines ever logged (plain text + colour codes)

# Write one line to the log buffer and repaint visible area
log() {
    local text="$1"
    _LOG_BUF+=("$text")
    _repaint_log
}

# Section separator with a label inside the log
log_section() {
    local title="  ── $1 ──"
    local inner=$(( PANEL_W - 4 ))
    local tl=$(( ${#title} - 10 ))   # rough visible length (strip colour codes)
    local sep_len=$(( inner - tl - 2 ))
    (( sep_len < 2 )) && sep_len=2
    _LOG_BUF+=("${BOLD}${Y}${title} ${DIM}${RST}")
    _repaint_log
}

_repaint_log() {
    local total=${#_LOG_BUF[@]}
    local start=0
    (( total > LOG_MAX_ROWS )) && start=$(( total - LOG_MAX_ROWS ))
    local row="$LOG_TOP"
    local inner=$(( PANEL_W - 4 ))
    for (( i=start; i<total && row<PANEL_ROW-1; i++, row++ )); do
        _cup "$row" "$LOG_COL"
        # pad to inner width to overwrite stale content
        printf "%-${inner}s" ""
        _cup "$row" "$LOG_COL"
        printf "%s" "${_LOG_BUF[$i]}"
    done
    # blank any leftover rows
    for (( ; row<PANEL_ROW-1; row++ )); do
        _cup "$row" "$LOG_COL"
        printf "%-${inner}s" ""
    done
}

# ═══════════════════════════════════════════════════════════
#   PROGRESS BAR
# ═══════════════════════════════════════════════════════════
_draw_bar() {
    local row=$1 col=$2 bw=$3 pct=$4
    (( pct <   0 )) && pct=0
    (( pct > 100 )) && pct=100
    local fill=$(( bw * pct / 100 ))
    local empty=$(( bw - fill ))
    local fc="$G"
    (( pct >= 50  )) && fc="$C"
    (( pct >= 80  )) && fc="$Y"
    (( pct == 100 )) && fc="${G}"

    _cup "$row" "$col"
    printf "${DIM}[${RST}${fc}"
    (( fill  > 0 )) && printf '█%.0s' $(seq 1 "$fill")
    printf "${DIM}"
    (( empty > 0 )) && printf '░%.0s' $(seq 1 "$empty")
    printf "${RST}${DIM}]${RST} ${BOLD}%3d%%${RST}" "$pct"
}

# ═══════════════════════════════════════════════════════════
#   STATUS PANEL  (bottom box, updated every tick)
# ═══════════════════════════════════════════════════════════
TASK_TOTAL=0
TASK_DONE=0
TASK_PASS=0
TASK_FAIL=0

# Cache last values for resize redraw
_LAST_LABEL=""
_LAST_ELAPSED=0
_LAST_DL=0
_LAST_PCT=0

_update_panel() {
    local label="$1" elapsed="$2" dl_bytes="$3" task_pct="$4"
    _LAST_LABEL="$label"
    _LAST_ELAPSED="$elapsed"
    _LAST_DL="$dl_bytes"
    _LAST_PCT="$task_pct"

    local pr=$(( PANEL_ROW + 1 ))
    local pc=3
    local pw=$(( PANEL_W - 4 ))
    local bar_w=$(( pw - 20 ))
    (( bar_w < 10 )) && bar_w=10

    # Row 1 — task label (truncate to fit)
    _cup "$pr" "$pc"
    printf "${BOLD}${C}%-${pw}s${RST}" "${label:0:$pw}"
    _el

    # Row 2 — task progress bar
    _draw_bar $(( pr+1 )) "$pc" "$bar_w" "$task_pct"
    _el

    # Row 3 — elapsed + download
    _cup $(( pr+2 )) "$pc"
    printf "${DIM}Elapsed :${RST} ${Y}%-8s${RST}" "$(_fmt_time "$elapsed")"
    if (( dl_bytes > 0 )); then
        printf "  ${DIM}Downloaded :${RST} ${C}%s${RST}" "$(_fmt_size "$dl_bytes")"
    fi
    _el

    # Row 4 — overall bar
    local overall=0
    (( TASK_TOTAL > 0 )) && overall=$(( TASK_DONE * 100 / TASK_TOTAL ))
    local bar2_w=$(( pw - 26 ))
    (( bar2_w < 10 )) && bar2_w=10
    _cup $(( pr+3 )) "$pc"
    printf "${DIM}Overall :${RST} ${G}%3d${RST}${DIM}/${RST}${W}%-3d${RST}  " \
        "$TASK_DONE" "$TASK_TOTAL"
    _draw_bar $(( pr+3 )) $(( pc+14 )) "$bar2_w" "$overall"
    _el

    # Row 5 — pass / fail counts
    _cup $(( pr+4 )) "$pc"
    printf "${G}✔  %-3d passed${RST}   ${R}✘  %-3d failed${RST}" \
        "$TASK_PASS" "$TASK_FAIL"
    _el
}

# ═══════════════════════════════════════════════════════════
#   HELPERS
# ═══════════════════════════════════════════════════════════
_fmt_time() {
    local s=$1
    (( s < 60 )) && printf "%ds" "$s" \
                 || printf "%dm%02ds" "$(( s/60 ))" "$(( s%60 ))"
}

_fmt_size() {
    local b=$1
    if   (( b < 1024 ));    then printf "%dB"   "$b"
    elif (( b < 1048576 )); then
        awk "BEGIN{printf \"%.1fKB\",$b/1024}"
    else
        awk "BEGIN{printf \"%.1fMB\",$b/1048576}"
    fi
}

_get_dl_bytes() {
    grep -oP '\[\K[0-9.]+ [kMG]?B(?=\])' "$1" 2>/dev/null | awk '
        { v=$1; u=$2
          if      (u=="kB"||u=="KB") s+=v*1024
          else if (u=="MB")          s+=v*1048576
          else if (u=="GB")          s+=v*1073741824
          else                       s+=v
        } END { printf "%.0f", s+0 }'
}

SPIN_F=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

# ═══════════════════════════════════════════════════════════
#   run_task  [--dl]  "Label"  cmd [args...]
# ═══════════════════════════════════════════════════════════
run_task() {
    local track_dl=0
    [[ "$1" == "--dl" ]] && { track_dl=1; shift; }
    local label="$1"; shift
    (( TASK_TOTAL++ ))

    local tmp; tmp=$(mktemp)
    local t0;  t0=$(date +%s)
    local fi=0

    _civis
    "$@" >"$tmp" 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local now; now=$(date +%s)
        local el=$(( now - t0 ))
        local dl=0
        (( track_dl )) && dl=$(_get_dl_bytes "$tmp")

        local pct=$(( el * 3 )); (( pct > 95 )) && pct=95

        local spin="${SPIN_F[$(( fi % ${#SPIN_F[@]} ))]}"
        (( fi++ ))

        _update_panel "${spin}  ${label}" "$el" "$dl" "$pct"
        sleep 0.08
    done

    wait "$pid"; local rc=$?
    local elapsed=$(( $(date +%s) - t0 ))
    local dl=0; (( track_dl )) && dl=$(_get_dl_bytes "$tmp")

    (( TASK_DONE++ ))

    local extra=""
    (( dl > 0 )) && extra="  ${C}↓$(_fmt_size $dl)${RST}"

    if (( rc == 0 )); then
        (( TASK_PASS++ ))
        _update_panel "✔  ${label}" "$elapsed" "$dl" 100
        log "  ${G}✔${RST}  ${label}  ${DIM}[$(_fmt_time "$elapsed")]${RST}${extra}"
    else
        (( TASK_FAIL++ ))
        _update_panel "✘  ${label}" "$elapsed" "$dl" 100
        log "  ${R}✘${RST}  ${label}  ${DIM}[$(_fmt_time "$elapsed")]${RST}"
        { echo "[$(date +'%F %T')] FAIL: $label"; cat "$tmp"; } >> "$ERROR_LOG"
    fi

    rm -f "$tmp"
    _cnorm
    return "$rc"
}

# ═══════════════════════════════════════════════════════════
#   NETWORK CHECK
# ═══════════════════════════════════════════════════════════
check_network() {
    log_section "NETWORK CHECK"
    log "  ${C}⟳${RST}  Pinging 8.8.8.8..."
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        log "  ${G}✔${RST}  Connection ${G}OK${RST}"
    else
        log "  ${R}✘${RST}  ${R}No internet — reconnect and retry.${RST}"
        _cnorm; sleep 3; tput rmcup 2>/dev/null; exit 1
    fi
}

# ═══════════════════════════════════════════════════════════
#   THEME SELECTOR  (full-screen, outside alt-buffer)
# ═══════════════════════════════════════════════════════════
select_theme() {
    # leave the alt buffer while the menu is shown
    tput rmcup 2>/dev/null
    _cnorm

    while true; do
        tput clear 2>/dev/null
        _refresh_dims

        local art_w=49 art_h=6
        local ar=$(( (LINES - art_h - 12) / 2 )); (( ar < 1 )) && ar=1
        local ac=$(( (COLS  - art_w)      / 2 )); (( ac < 0 )) && ac=0

        local ART=(
          "  ████████╗██╗  ██╗███████╗███╗   ███╗███████╗"
          "  ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝"
          "     ██║   ███████║█████╗  ██╔████╔██║█████╗  "
          "     ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝  "
          "     ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗"
          "     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝"
        )
        for (( i=0; i<${#ART[@]}; i++ )); do
            _cup $(( ar+i )) "$ac"
            printf "${M}%s${RST}" "${ART[$i]}"
        done

        _cup $(( ar+art_h )) $(( ac+11 ))
        printf "${DIM}Termux Theme Installer  v4.0${RST}"

        local mw=34 mh=10
        local mr=$(( ar + art_h + 2 ))
        local mc=$(( (COLS - mw) / 2 ))

        # menu box
        _cup "$mr" "$mc";                printf "${DIM}╔"; printf '═%.0s' $(seq 1 $(( mw-2 ))); printf "╗${RST}"
        for (( i=1; i<mh-1; i++ )); do
            _cup $(( mr+i )) "$mc";       printf "${DIM}║${RST}%-$(( mw-2 ))s${DIM}║${RST}" " "
        done
        _cup $(( mr+mh-1 )) "$mc";       printf "${DIM}╚"; printf '═%.0s' $(seq 1 $(( mw-2 ))); printf "╝${RST}"

        # header inside box
        _cup $(( mr+1 )) $(( mc+2 ))
        printf "${BOLD}${C}%-$(( mw-4 ))s${RST}" "  SELECT THEME"
        _cup $(( mr+2 )) $(( mc+2 ))
        printf "${DIM}%-$(( mw-4 ))s${RST}" "$(printf '─%.0s' $(seq 1 $(( mw-4 ))))"

        _cup $(( mr+3 )) $(( mc+4 )); printf "${BOLD}${C}1)${RST}  🖤  Black Theme"
        _cup $(( mr+4 )) $(( mc+4 )); printf "${BOLD}${C}2)${RST}  🎨  Color Theme"
        _cup $(( mr+5 )) $(( mc+2 )); printf "${DIM}%-$(( mw-4 ))s${RST}" "$(printf '─%.0s' $(seq 1 $(( mw-4 ))))"
        _cup $(( mr+6 )) $(( mc+4 )); printf "${BOLD}${R}3)${RST}  🗑️   Uninstall"
        _cup $(( mr+7 )) $(( mc+4 )); printf "${BOLD}${Y}4)${RST}  ✕   Exit"

        _cup $(( mr+mh+1 )) $(( mc+2 ))
        read -rp "$(printf "  ${BOLD}${M}Select [1-4]: ${RST}")" choice

        case "$choice" in
            1) THEME_DIR="black"
               tput clear 2>/dev/null
               _init_ui
               return 0 ;;
            2) THEME_DIR="color"
               tput clear 2>/dev/null
               _init_ui
               return 0 ;;
            3) tput clear 2>/dev/null
               _init_ui
               _do_uninstall
               tput rmcup 2>/dev/null; _cnorm; exit 0 ;;
            4) tput rmcup 2>/dev/null; _cnorm
               echo -e "\n${Y}Bye!${RST}"; exit 0 ;;
            *)
               _cup $(( mr+mh+2 )) $(( mc+2 ))
               printf "${R}Invalid. Enter 1–4.${RST}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#   INSTALL STEPS
# ═══════════════════════════════════════════════════════════

_fix_repos() {
    [ -f "$PREFIX/etc/apt/sources.list" ] && \
        cp "$PREFIX/etc/apt/sources.list" \
           "$PREFIX/etc/apt/sources.list.bak" 2>/dev/null
    printf 'deb https://packages.termux.dev/apt/termux-main stable main\n' \
        > "$PREFIX/etc/apt/sources.list"
    run_task --dl "Updating repository index" apt update
}

install_packages() {
    log_section "PACKAGE INSTALLATION"
    log "  ${Y}⚠${RST}  May take 10–20 min on slow connections"

    _fix_repos
    run_task             "Upgrading system"                   apt upgrade -y
    run_task --dl        "Core: zsh git python figlet lsd"   pkg install zsh git wget curl python figlet lsd logo-ls ncurses-utils -y
    run_task --dl        "Dev:  neovim lua ripgrep lazygit"  pkg install neovim lua-language-server ripgrep lazygit -y
    run_task --dl        "Ruby + figlet"                     pkg install figlet ruby -y
    run_task --dl        "Build tools & extras"              apt install build-essential zip termux-api gdu gdb gdbserver gh fd fzf neovim lua-language-server jq-lsp luarocks stylua ripgrep yarn python-pip ccls clang zig rust-analyzer -y
    run_task             "pip: neovim"                       pip install neovim
    run_task --dl        "npm: neovim"                       npm install -g neovim
    run_task             "gem: neovim"                       gem install neovim
    run_task             "gem: lolcat"                       gem install lolcat
}

setup_fonts_and_config() {
    log_section "FONTS & CONFIG"
    mkdir -p ~/.termux

    run_task "Nerd Font → ~/.termux/font.ttf"           cp -f "$HOME/Tmx-theme/src/font.ttf"           ~/.termux/
    run_task "figlet ASCII-Shadow font"                  cp -f "$HOME/Tmx-theme/src/ASCII-Shadow.flf"   "$PREFIX/share/figlet/" 2>/dev/null || true
    run_task "Theme config → ~/.p10k.zsh"               cp -f "$HOME/Tmx-theme/$THEME_DIR/.p10k.zsh"   "$HOME/.p10k.zsh"
    run_task "~/.termux/termux.properties"              cp -f "$HOME/Tmx-theme/src/termux.properties"  "$HOME/.termux/termux.properties"
    run_task "~/.termux/colors.properties"              cp -f "$HOME/Tmx-theme/src/colors.properties"  "$HOME/.termux/colors.properties"
    run_task "~/.zshrc"                                 cp -f "$HOME/Tmx-theme/src/.zshrc"             "$HOME/.zshrc"
    run_task "~/.banner.sh"                             cp -f "$HOME/Tmx-theme/src/.banner.sh"         "$HOME/.banner.sh"
    run_task "~/.draw"                                  cp -f "$HOME/Tmx-theme/src/.draw"              "$HOME/.draw"
    run_task "~/.draw.sh"                               cp -f "$HOME/Tmx-theme/src/.draw.sh"           "$HOME/.draw.sh"
    run_task "/usr/etc/zshrc"                           cp -f "$HOME/Tmx-theme/src/zshrc"              "$PREFIX/etc/zshrc"
    run_task "termux-reload-settings"                   termux-reload-settings
}

setup_zsh_plugins() {
    log_section "ZSH PLUGINS"
    mkdir -p ~/.oh-my-zsh/{plugins,custom/themes} "$PREFIX/etc/.plugin"

    if [ ! -d ~/.oh-my-zsh/.git ]; then
        run_task --dl "Oh My Zsh" \
            git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    else
        log "  ${DIM}✔  Oh My Zsh already present — skip${RST}"
        (( TASK_DONE++ )); (( TASK_PASS++ ))
    fi

    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        run_task --dl "Powerlevel10k" \
            git clone --depth 1 https://github.com/romkatv/powerlevel10k.git \
            ~/.oh-my-zsh/custom/themes/powerlevel10k
    else
        log "  ${DIM}✔  Powerlevel10k already present — skip${RST}"
        (( TASK_DONE++ )); (( TASK_PASS++ ))
    fi

    _clone_plugin() {
        local repo="$1" target="$2"
        local name="${repo##*/}"
        if [ ! -d "$target" ]; then
            run_task --dl "Plugin: $name" \
                git clone --depth 1 "https://github.com/$repo" "$target"
        else
            log "  ${DIM}✔  $name already present — skip${RST}"
            (( TASK_DONE++ )); (( TASK_PASS++ ))
        fi
    }

    _clone_plugin "zsh-users/zsh-completions"              "$HOME/.oh-my-zsh/plugins/zsh-completions"
    _clone_plugin "zsh-users/zsh-history-substring-search" "$HOME/.oh-my-zsh/plugins/zsh-history-substring-search"
    _clone_plugin "bobthecow/git-flow-completion"          "$HOME/.oh-my-zsh/plugins/git-flow-completion"
    _clone_plugin "zsh-users/zsh-syntax-highlighting"      "$PREFIX/etc/.plugin/zsh-syntax-highlighting"
    _clone_plugin "zsh-users/zsh-autosuggestions"          "$PREFIX/etc/.plugin/zsh-autosuggestions"
}

setup_astronvim() {
    log_section "ASTRONVIM"
    [ -d ~/.config/nvim ] && run_task "Remove old nvim config" rm -rf ~/.config/nvim
    run_task --dl "Clone AstroNvim" \
        git clone --depth 1 https://github.com/tharindu899/tmx-nvim.git ~/.config/nvim
}

_do_uninstall() {
    log_section "UNINSTALL"
    run_task "Removing theme files" \
        rm -rf ~/.termux ~/.zshrc ~/.p10k.zsh ~/.banner.sh ~/.oh-my-zsh ~/.config/nvim
    termux-reload-settings
    log "  ${G}✔${RST}  Uninstall complete."
}

# ═══════════════════════════════════════════════════════════
#   DONE  — update panel, add final log line, leave screen
# ═══════════════════════════════════════════════════════════
show_done() {
    log_section "COMPLETE"

    local fail_color="$G"
    (( TASK_FAIL > 0 )) && fail_color="$R"

    log "  ${G}✔${RST}  ${BOLD}All done!${RST}  Theme: ${C}${THEME_DIR^}${RST}"
    log "  ${DIM}Passed : ${RST}${G}${TASK_PASS}${RST}   ${DIM}Failed : ${RST}${fail_color}${TASK_FAIL}${RST}"
    log "  ${DIM}Run ${RST}${C}${BOLD}zsh${RST}${DIM} to start your new shell.${RST}"

    # Final panel update — full overall bar
    _update_panel "✔  Installation complete!" 0 0 100

    # Replace overall bar with 100% green and freeze
    local pr=$(( PANEL_ROW + 4 ))
    local pc=3
    local pw=$(( PANEL_W - 4 ))
    local bar2_w=$(( pw - 26 ))
    (( bar2_w < 10 )) && bar2_w=10
    _cup "$pr" "$pc"
    printf "${DIM}Overall :${RST} ${G}%3d${RST}${DIM}/${RST}${W}%-3d${RST}  " \
        "$TASK_DONE" "$TASK_TOTAL"
    _draw_bar "$pr" $(( pc+14 )) "$bar2_w" 100

    # Move cursor below the UI so the shell prompt appears cleanly on exit
    _cup $(( LINES - 1 )) 0
    _cnorm

    # ── leave alt screen buffer ───────────────────────────
    # Screen is NOT cleared — tput rmcup restores the old buffer
    # but the installer content remains visible because we exit
    # the alt buffer and the terminal scrollback shows it.
    tput rmcup 2>/dev/null

    echo -e "\n${G}${BOLD}✔  Setup complete!${RST}  Type ${C}zsh${RST} to start.\n"
    log_section "FINALIZING"
    run_task "Set default shell to zsh" chsh -s zsh
}

# ═══════════════════════════════════════════════════════════
#   MAIN
# ═══════════════════════════════════════════════════════════

# 1. Menu runs in normal screen
select_theme

# 2. All install work runs in alt-screen (init called inside select_theme on confirm)
check_network

# Pre-set total for accurate overall bar
TASK_TOTAL=30

install_packages
setup_fonts_and_config
setup_zsh_plugins
setup_astronvim
show_done
