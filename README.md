
# 🎨 Termux Theme

<div align="center">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue" alt="Version">
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
- Dual theme options (Dark/Color)
- Powerlevel10k Zsh prompt
- Custom Nerd Fonts
- Pre-configured Neovim IDE
- One-click installation
- Automatic dependency resolver

## 🚀 Quick Install
```bash
# Run this in Termux

```
## 📂 Directory Structure
```env
~/T-banner/
├── 📜 install.sh              # Main installation script
├── 📁 black/                 # Dark theme package
│   ├── 🎨 font.ttf           # Nerd Font for icons
│   ├── ⚙️ termux.properties  # Termux settings/config
│   ├── 🖌️ colors.properties  # Color scheme definitions
│   ├── 🐧 .zshrc             # ZSH configuration file
│   ├── ⚡ .p10k.zsh          # Powerlevel10k theme config
│   ├── 🖼️ .banner.sh         # Custom login banner script
│   ├── 🎭 .draw              # ASCII art database
│   ├── ✏️ .draw.sh           # Drawing script
│   ├── 📜 zshrc              # System-wide ZSH config
│   └── 🖋️ ASCII-Shadow.flf   # Custom figlet font
└── 📁 color/                 # Color same us black
```

## 📥 Installation Options

### Method 1: Network Install
```bash
pkg install curl -y && curl -sL https://git.io/termux-theme | bash
```

### Method 2: Manual Install
```bash
# Step 1: Clone repo
pkg update -y
pkg install git -y
git clone https://github.com/tharinsu899/Tmx-theme.git ~/t-banner
```

```bash
# Step 2: Run installer
cd ~/t-banner
bash install.sh

# Step 3: Select theme (1/2/3)
```

## 🖼️ Theme Previews
| Color Theme | Black Theme |
|-------------|-------------|
| <img src="https://i.imgur.com/84qJ3vP.jpeg" width="300"> | <img src="https://i.imgur.com/FUwyvU8.jpeg" width="300"> |

## 📋 File Locations
| Config File          | Destination               |
|----------------------|---------------------------|
| `theme/*/font.ttf`   | `$HOME/.termux/font.ttf`  |
| `theme/*/.zshrc`     | `$HOME/.zshrc`            |
| `theme/*/termux.properties` | `$HOME/.termux/termux.properties` |

## 🛠️ Included Tools
| Category       | Tools                              |
|----------------|------------------------------------|
| Core           | Zsh, Git, Python, Ruby, Nodejs     |
| CLI Tools      | Lsd, Bat, Ripgrep, Fzf, Lazygit    |
| Development    | Neovim, Lua, LSP, Debuggers        |
| Visual         | Figlet, Lolcat, Ncurses-utils      |

## ❓ FAQ
### Q: How to switch themes?
```bash
# Re-run installer
bash ~/T-banner/install.sh
```

### Q: Where are configs stored?
```
~/.termux/
~/.zshrc
~/.p10k.zsh
~/.config/nvim/
```

### Q: How to update?
```bash
cd ~/T-banner && git pull && bash install.sh
```

## 🗑️ Uninstall
```bash
# Using installer
bash ~/T-banner/install.sh # Choose option 3

# Manual removal
rm -rf ~/.termux ~/.zsh* ~/.oh-my-zsh ~/.config/nvim
termux-reload-settings
```
___
## 📌 Important Notes
1. Allow Termux storage permissions
2. Restart Termux after installation
3. First launch may take 2-3 minutes
___
⭐ **Pro Tip**: Use `ctrl + t` for quick file manager access!

💻 **Developed with ❤️ by [Tharindu Prabath]**
🔗 **Credits**: Based on work by [remo7777](https://github.com/remo7777/T-Header)

📧 **Support**: tprabath81@gmail.com
```
