#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# TMX-THEME
# GitHub Dual Account Automatic Configuration
#
# Account 1:
#   tharindu899 -> ~/.config/gh-account1
#
# Account 2:
#   cineflow-web -> ~/.config/gh-account2
#
# Git automatically selects the account from the repository
# owner. Works with normal git, LazyVim and lazygit.
# ============================================================

set -Eeuo pipefail

GH1_USER="tharindu899"
GH2_USER="cineflow-web"

GH1_CONFIG="$HOME/.config/gh-account1"
GH2_CONFIG="$HOME/.config/gh-account2"

GH1_GITCONFIG="$HOME/.gitconfig-gh1"
GH2_GITCONFIG="$HOME/.gitconfig-gh2"

GITCONFIG="$HOME/.gitconfig"

MARKER_START="# === TMX-THEME GITHUB DUAL ACCOUNT START ==="
MARKER_END="# === TMX-THEME GITHUB DUAL ACCOUNT END ==="

log() {
    printf '  \033[1;36m→\033[0m %s\n' "$1"
}

success() {
    printf '  \033[1;32m✔\033[0m %s\n' "$1"
}

warning() {
    printf '  \033[1;33m⚠\033[0m %s\n' "$1"
}

error() {
    printf '  \033[1;31m✘\033[0m %s\n' "$1"
}

# ------------------------------------------------------------
# Check Termux
# ------------------------------------------------------------

if [[ -z "${PREFIX:-}" ]]; then
    warning "PREFIX is not set. This script is designed for Termux."
fi

# ------------------------------------------------------------
# Check Git
# ------------------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
    error "Git is not installed."
    exit 1
fi

# ------------------------------------------------------------
# Check GitHub CLI
# ------------------------------------------------------------

if ! command -v gh >/dev/null 2>&1; then
    error "GitHub CLI (gh) is not installed."
    echo
    echo "Install it with:"
    echo "  pkg install gh -y"
    exit 1
fi

# ------------------------------------------------------------
# Create directories
# ------------------------------------------------------------

log "Creating GitHub CLI account directories..."

mkdir -p "$GH1_CONFIG"
mkdir -p "$GH2_CONFIG"

success "GitHub account directories ready."

# ------------------------------------------------------------
# Create gh1 Git credential configuration
# ------------------------------------------------------------

log "Configuring gh1 → $GH1_USER..."

cat > "$GH1_GITCONFIG" <<'EOF'
[credential "https://github.com"]
    helper =
    helper = !GH_CONFIG_DIR=$HOME/.config/gh-account1 gh auth git-credential
EOF

success "Created $GH1_GITCONFIG"

# ------------------------------------------------------------
# Create gh2 Git credential configuration
# ------------------------------------------------------------

log "Configuring gh2 → $GH2_USER..."

cat > "$GH2_GITCONFIG" <<'EOF'
[credential "https://github.com"]
    helper =
    helper = !GH_CONFIG_DIR=$HOME/.config/gh-account2 gh auth git-credential
EOF

success "Created $GH2_GITCONFIG"

# ------------------------------------------------------------
# Validate generated files
# ------------------------------------------------------------

log "Validating GitHub account configuration files..."

git config --file "$GH1_GITCONFIG" --list >/dev/null
git config --file "$GH2_GITCONFIG" --list >/dev/null

success "GitHub account configuration is valid."

# ------------------------------------------------------------
# Backup global Git config
# ------------------------------------------------------------

if [[ -f "$GITCONFIG" ]]; then
    BACKUP="$GITCONFIG.tmx-backup-$(date +%Y%m%d-%H%M%S)"

    cp "$GITCONFIG" "$BACKUP"

    success "Backed up ~/.gitconfig → $BACKUP"
else
    touch "$GITCONFIG"
fi

# ------------------------------------------------------------
# Remove old generic GitHub credential helper
#
# This is important because a generic:
#
# [credential "https://github.com"]
#     helper = !gh auth git-credential
#
# can authenticate using the wrong account.
# ------------------------------------------------------------

log "Removing old generic GitHub credential helper..."

git config --global --unset-all 'credential.https://github.com.helper' 2>/dev/null || true

# ------------------------------------------------------------
# Remove previous TMX automatic configuration block
# ------------------------------------------------------------

if grep -qF "$MARKER_START" "$GITCONFIG" 2>/dev/null; then

    log "Removing previous TMX GitHub configuration..."

    sed -i \
        "/^$(printf '%s' "$MARKER_START" | sed 's/[]\/$*.^[]/\\&/g')$/,/^$(printf '%s' "$MARKER_END" | sed 's/[]\/$*.^[]/\\&/g')$/d" \
        "$GITCONFIG"

fi

# ------------------------------------------------------------
# Enable HTTP path matching
# ------------------------------------------------------------

git config --global credential.useHttpPath true

# ------------------------------------------------------------
# Add automatic account selection
# ------------------------------------------------------------

log "Installing automatic GitHub account selection..."

cat >> "$GITCONFIG" <<EOF

$MARKER_START

[includeIf "hasconfig:remote.*.url:https://github.com/$GH1_USER/**"]
    path = ~/.gitconfig-gh1

[includeIf "hasconfig:remote.*.url:https://github.com/$GH2_USER/**"]
    path = ~/.gitconfig-gh2

$MARKER_END
EOF

# ------------------------------------------------------------
# Validate global Git config
# ------------------------------------------------------------

log "Validating ~/.gitconfig..."

if git config --global --list >/dev/null 2>&1; then
    success "Global Git configuration is valid."
else
    error "Global Git configuration is invalid."

    echo
    echo "Your previous configuration was backed up."
    exit 1
fi

# ------------------------------------------------------------
# Optional Zsh aliases
# ------------------------------------------------------------

ZSHRC="$HOME/.zshrc"

if [[ -f "$ZSHRC" ]]; then

    log "Updating GitHub aliases in ~/.zshrc..."

    # Remove old TMX-managed aliases only.
    sed -i '/^# === TMX-THEME GITHUB ACCOUNTS START ===$/,/^# === TMX-THEME GITHUB ACCOUNTS END ===$/d' "$ZSHRC"

    cat >> "$ZSHRC" <<'EOF'

# === TMX-THEME GITHUB ACCOUNTS START ===

alias gh1='GH_CONFIG_DIR="$HOME/.config/gh-account1" gh'
alias gh2='GH_CONFIG_DIR="$HOME/.config/gh-account2" gh'

# === TMX-THEME GITHUB ACCOUNTS END ===
EOF

    success "gh1 / gh2 aliases installed."

else
    warning "~/.zshrc does not exist yet. Aliases will be available after Zsh setup."
fi

# ------------------------------------------------------------
# Test GitHub CLI accounts
# ------------------------------------------------------------

echo
echo "────────────────────────────────────────────────────────"
echo " GitHub account status"
echo "────────────────────────────────────────────────────────"

echo

if GH_CONFIG_DIR="$GH1_CONFIG" gh auth status >/dev/null 2>&1; then
    success "gh1 is authenticated."
else
    warning "gh1 is not authenticated yet."
    echo "      Login with:"
    echo "      GH_CONFIG_DIR=$GH1_CONFIG gh auth login"
fi

if GH_CONFIG_DIR="$GH2_CONFIG" gh auth status >/dev/null 2>&1; then
    success "gh2 is authenticated."
else
    warning "gh2 is not authenticated yet."
    echo "      Login with:"
    echo "      GH_CONFIG_DIR=$GH2_CONFIG gh auth login"
fi

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo
echo "────────────────────────────────────────────────────────"
echo " GitHub Dual Account Setup Complete"
echo "────────────────────────────────────────────────────────"
echo
echo "  $GH1_USER/*     → gh1"
echo "  $GH2_USER/*     → gh2"
echo
echo "  Normal git push automatically selects the account."
echo "  LazyVim/lazygit also use the same configuration."
echo
echo "  Reload Zsh:"
echo "    source ~/.zshrc"
echo