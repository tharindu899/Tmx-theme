
# 🎨 Termux Theme

<div align="center">
  <img src="https://img.shields.io/badge/Version-4.0.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Platform-Termux-orange" alt="Platform">
</div>

<p align="center">
  <img src="https://github.com/tharindu899/Tmx-theme/blob/master/src/img/tmx5.jpg" alt="tmx5" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Termux_Theme_Customizer-2D3436?style=for-the-badge&logo=android&logoColor=white&labelColor=2D3436" />
</p>

## ✨ Features

- Dual theme options (🖤 Black / 🎨 Color)
- Interactive TUI installer with live log & animated progress bars
- Network check before installation begins
- Powerlevel10k Zsh prompt
- Custom Nerd Fonts
- Pre-configured Neovim / AstroNvim IDE
- Oh My Zsh + curated plugin set
- One-click uninstall
- Automatic dependency resolver
- Failed-task error log at `~/skip_errors.log`

---

## 📂 Directory Structure

```
~/Tmx-theme/
  ├── 📜 install.sh              # Main installation script (v4.0)
  ├── 📁 src/                    # Needed assets & configs
  │   ├── 🎨 font.ttf            # Nerd Font for icons
  │   ├── ⚙️  termux.properties  # Termux settings/config
  │   ├── 🖌️  colors.properties  # Color scheme definitions
  │   ├── 🐧 .zshrc              # ZSH configuration file
  │   ├── 🖼️  .banner.sh         # Custom login banner script
  │   ├── 🎭 .draw               # ASCII art database
  │   ├── ✏️  .draw.sh           # Drawing script
  │   ├── 📜 zshrc               # System-wide ZSH config
  │   └── 🖋️  ASCII-Shadow.flf   # Custom figlet font
  ├── 📁 black/                  # Dark theme package
  │   └── ⚡ .p10k.zsh           # Powerlevel10k classic theme
  └── 📁 color/                  # Colorful theme package
       └── ⚡ .p10k.zsh          # Powerlevel10k rainbow theme
```

---

## 📥 Installation

### ⚙️ Step 1 — Prerequisites (run this first on a fresh Termux)

The installer uses `tput` for its TUI from the very first line, so you need a small set of packages **before** cloning the repo. Run this once on a brand-new Termux:

```bash
pkg update -y && pkg install git bash ncurses-utils -y
```

| Package | Why it's needed |
|---|---|
| `git` | Clone the repo |
| `bash` | Run `install.sh` |
| `ncurses-utils` | Provides `tput` — required for the TUI installer UI |

> Everything else (Zsh, Neovim, Oh My Zsh, plugins, fonts…) is installed automatically by the script.

---

### 🚀 Step 2 — Clone & Run

```bash
git clone https://github.com/tharindu899/Tmx-theme.git ~/Tmx-theme && \
cd ~/Tmx-theme && \
chmod +x install.sh && \
bash install.sh
```

### 🖥️ Installer Menu

When you run `install.sh` a full-screen TUI appears with four options:

| Option | Action |
|--------|--------|
| `1` | Install **Black Theme** (classic dark prompt) |
| `2` | Install **Color Theme** (rainbow powerline prompt) |
| `3` | **Uninstall** — removes all theme files |
| `4` | Exit |

The installer checks your internet connection first, then runs all steps with a live scrolling log and real-time progress bars.

---

## 🖼️ Theme Previews

| Color Theme | Black Theme |
|-------------|-------------|
| <img src="https://i.imgur.com/84qJ3vP.jpeg" width="300"> | <img src="https://i.imgur.com/FUwyvU8.jpeg" width="300"> |

---

## 📋 File Locations

| Config File | Destination |
|---|---|
| `src/font.ttf` | `~/.termux/font.ttf` |
| `src/.zshrc` | `~/.zshrc` |
| `src/termux.properties` | `~/.termux/termux.properties` |
| `src/colors.properties` | `~/.termux/colors.properties` |
| `src/.banner.sh` | `~/.banner.sh` |
| `src/.draw` / `src/.draw.sh` | `~/.draw` / `~/.draw.sh` |
| `src/ASCII-Shadow.flf` | `$PREFIX/share/figlet/` |
| `src/zshrc` | `$PREFIX/etc/zshrc` |
| `{black,color}/.p10k.zsh` | `~/.p10k.zsh` |

---

## 🛠️ Installed Tools

| Category | Tools |
|---|---|
| **Core** | Zsh, Git, Python, wget, curl |
| **CLI Tools** | lsd, logo-ls, bat, ripgrep, fd, fzf, figlet, lolcat, ncurses-utils |
| **Development** | Neovim, Lua, lua-language-server, lazygit, luarocks, stylua |
| **Build & Extras** | build-essential, clang, zig, ccls, rust-analyzer, yarn, jq-lsp |
| **Shell** | Oh My Zsh, Powerlevel10k, zsh-syntax-highlighting, zsh-autosuggestions |
| **Utilities** | termux-api, gdu, gdb, gh (GitHub CLI), zip |
| **Neovim** | neovim pip/npm/gem providers, AstroNvim (`tharindu899/tmx-nvim`) |

---

## 🔌 Oh My Zsh Plugins

`copypath` · `dircycle` · `extract` · `frontend-search` · `git` · `git-auto-fetch` · `git-flow-completion` · `gitfast` · `git-prompt` · `ionic` · `pre-commit` · `safe-paste` · `web-search` · `zsh-completions` · `zsh-history-substring-search` · `zsh-syntax-highlighting` · `zsh-autosuggestions`

---

## ❓ FAQ

### Q: How do I switch themes?

```bash
bash ~/Tmx-theme/install.sh   # choose 1 or 2 from the menu
```

### Q: Where are configs stored?

```
~/.termux/
~/.zshrc
~/.p10k.zsh
~/.config/nvim/
```

### Q: Something failed — where is the error log?

Failed tasks are recorded to `~/skip_errors.log` with timestamps. You can view it with:

```bash
cat ~/skip_errors.log
```

### Q: How do I start the new shell after install?

```bash
zsh
```

The installer also sets Zsh as your default shell automatically via `chsh`.

---

## 🗑️ Uninstall

```bash
# From the installer menu
bash ~/Tmx-theme/install.sh   # choose option 3

# Manual removal
rm -rf ~/.termux ~/.zsh* ~/.oh-my-zsh ~/.config/nvim ~/.banner.sh ~/.draw ~/.draw.sh ~/.p10k.zsh
termux-reload-settings
```

---

## 📌 Important Notes

1. Allow Termux storage permissions before installing
2. Restart Termux after installation completes
3. First launch may take 2–3 minutes (plugin compilation)
4. Installation requires an active internet connection

---

✨ **Pro Tip**: Press `Ctrl + T` to open a new Termux session instantly!

💻 **Crafted with ❤️ by [Tharindu899](https://github.com/tharindu899)**

🔗 **Credits**: Inspired by the amazing work of [remo7777](https://github.com/remo7777/T-Header) ⭐

📬 **Need Help?** Reach out: [tprabath81@gmail.com](mailto:tprabath81@gmail.com)
