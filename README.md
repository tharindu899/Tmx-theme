
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
___
## 📂 Directory Structure
```env
~/Tmx-theme/
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
___
## 📥 Installation option
### 🚀 Quick Install
- for termux
```bash
pkg update -y && \
pkg upgrade -y && \
pkg install git -y && \
git clone https://github.com/tharindu899/Tmx-theme.git ~/Tmx-theme && \
cd ~/Tmx-theme && \
chmod +x install.sh
```
```bash
bash install.sh
```
- for ubuntu
```bash
sudo apt update -y && \
sudo apt upgrade -y && \
sudo apt install git -y && \
git clone https://github.com/tharindu899/Tmx-theme.git ~/Tmx-theme && \
cd ~/Tmx-theme && \
chmod +x ubuntu.sh
```
```bash
bash ubuntu.sh
```
___

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
___
## ❓ FAQ
### Q: How to switch themes?
```bash
# Re-run installer
bash ~/Tmx-theme/install.sh
```

### Q: Where are configs stored?
```
~/.termux/
~/.zshrc
~/.p10k.zsh
~/.config/nvim/
```
___
## 🗑️ Uninstall
```bash
# Using installer
bash ~/Tmx-theme/install.sh # Choose option 3

# Manual removal
rm -rf ~/.termux ~/.zsh* ~/.oh-my-zsh ~/.config/nvim
termux-reload-settings
```
___
## 📌 Important Notes
1. Allow Termux storage permissions
2. Restart Termux after installation
3. First launch may take 2-3 minutes

---

✨ **Pro Tip**: Press `Ctrl + T` to launch the file manager instantly!

💻 **Crafted with ❤️ by [Tharindu899]**

🔗 **Credits**: Inspired by the amazing work of [remo7777](https://github.com/remo7777/T-Header) ⭐

📬 **Need Help?** Reach out: [Gmail](tprabath81@gmail.com)

---
