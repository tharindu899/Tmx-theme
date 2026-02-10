# 🎨 Tmx-Theme v3.0

<div align="center">

![Version](https://img.shields.io/badge/Version-3.0.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Termux%20%7C%20Ubuntu-orange)

**A beautiful, feature-rich terminal theme for Termux and Ubuntu**

[Features](#-features) • [Installation](#-installation) • [Themes](#-themes) • [Uninstall](#-uninstall) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📸 Preview

| Dark Theme | Colorful Theme |
|------------|----------------|
| ![Dark Theme](https://i.imgur.com/FUwyvU8.jpeg) | ![Color Theme](https://i.imgur.com/84qJ3vP.jpeg) |

---

## ✨ Features

### 🎯 Core Features
- ✅ **Two Beautiful Themes** - Dark and Colorful variants
- ✅ **Powerlevel10k Prompt** - Fast, customizable Zsh prompt
- ✅ **Nerd Fonts Support** - Icons and glyphs in your terminal
- ✅ **Smart Autocompletion** - Zsh autosuggestions and completions
- ✅ **Syntax Highlighting** - Color-coded command syntax
- ✅ **Custom Banner** - Dynamic ASCII art on startup
- ✅ **Auto Backup** - Saves your configs before installation

### 🛠️ Included Tools
- **Shell**: Zsh with Oh My Zsh
- **Theme**: Powerlevel10k
- **Editor**: Neovim (pre-configured)
- **CLI Tools**: ripgrep, fzf, figlet, lolcat
- **File Listing**: lsd (modern ls replacement)

---

## 📦 Installation

### Quick Install (One-Line)

**For Termux:**
```bash
pkg update -y && pkg install git -y && git clone https://github.com/tharindu899/Tmx-theme.git ~/Tmx-theme && cd ~/Tmx-theme && chmod +x install.sh && bash install.sh
```

**For Ubuntu/Debian:**
```bash
sudo apt update -y && sudo apt install git -y && git clone https://github.com/tharindu899/Tmx-theme.git ~/Tmx-theme && cd ~/Tmx-theme && chmod +x install.sh && bash install.sh
```

### Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/tharindu899/Tmx-theme.git
   cd Tmx-theme
   ```

2. **Run the installer**
   ```bash
   chmod +x install.sh
   bash install.sh
   ```

3. **Follow the interactive menu**
   - Choose your operating system
   - Select a theme (Dark or Colorful)
   - Confirm installation
   - Wait for completion (10-20 minutes)

4. **Restart your terminal**
   ```bash
   # Or reload configuration
   source ~/.zshrc
   ```

---

## 🎨 Themes

### 🌑 Dark Theme
- Clean black background
- Minimalist design
- Easy on the eyes
- Perfect for long coding sessions

### 🌈 Colorful Theme
- Vibrant color scheme
- Eye-catching visuals
- Distinct syntax highlighting
- Great for presentations

### Switching Themes
```bash
cd ~/Tmx-theme
bash install.sh
# Select option 1 (Install Theme)
# Choose different theme
```

---

## 📁 Project Structure

```
Tmx-theme/
├── install.sh              # Main installer script
├── README.md               # This file
├── black/                  # Dark theme files
│   ├── .zshrc             # Zsh configuration
│   ├── .p10k.zsh          # Powerlevel10k config
│   ├── .banner.sh         # Startup banner
│   ├── termux.properties  # Termux settings
│   ├── colors.properties  # Color scheme
│   └── font.ttf           # Nerd Font
└── color/                  # Colorful theme files
    └── (same structure as black/)
```

---

## 🔧 Configuration

### Customizing Your Prompt
```bash
# Run Powerlevel10k configuration wizard
p10k configure
```

### Editing Zsh Config
```bash
# Use your preferred editor
nano ~/.zshrc
# or
vim ~/.zshrc

# Reload after changes
source ~/.zshrc
```

### Customizing the Banner
```bash
# Edit banner script
nano ~/.banner.sh

# Change the displayed text in your .zshrc
# Look for: bash ~/.banner.sh ${cols} "Your-Text-Here"
```

---

## 🗑️ Uninstall

### Using the Installer
```bash
cd ~/Tmx-theme
bash install.sh
# Select option 2 (Uninstall Theme)
```

### Manual Uninstall
```bash
# Remove configuration files
rm -rf ~/.zshrc ~/.p10k.zsh ~/.banner.sh ~/.termux ~/.oh-my-zsh ~/.config/nvim

# Reset to bash (optional)
chsh -s $(which bash)

# Reload Termux settings (Termux only)
termux-reload-settings
```

**Note:** Installed packages (zsh, git, etc.) are NOT removed during uninstall.

---

## 📚 Useful Aliases

The theme includes helpful aliases:

```bash
# Package management
pi <package>   # Install package
pup            # Update package lists
pug            # Upgrade all packages

# Navigation
c              # Go up one directory
cdd            # Go to downloads folder

# File operations
d <file>       # Delete file/folder
f <name>       # Create directory

# Editor
n <file>       # Open in Neovim
z              # Edit .zshrc

# Configuration
rr             # Reload .zshrc
r              # Reload Termux settings
```

---

## 🐛 Troubleshooting

### Installation Failed
```bash
# Check the installation log
less ~/tmx-install.log

# Try fixing package repositories
pkg update && pkg upgrade

# Run installer again
cd ~/Tmx-theme && bash install.sh
```

### Fonts Not Displaying Correctly
1. Make sure you're using a Nerd Font compatible terminal
2. For Termux: The installer sets this automatically
3. For Ubuntu: Install a Nerd Font in your terminal emulator settings

### Zsh Not Default Shell
```bash
# Manually set Zsh as default
chsh -s $(which zsh)

# Restart terminal
```

### Theme Not Applied
```bash
# Reload configuration
source ~/.zshrc

# Or restart your terminal completely
```

### Permission Denied Errors
```bash
# Make script executable
chmod +x ~/Tmx-theme/install.sh

# For Termux, ensure storage permission
termux-setup-storage
```

---

## 🆘 Getting Help

### Before Asking for Help
1. Check the [installation log](#): `~/tmx-install.log`
2. Read this README thoroughly
3. Check [existing issues](https://github.com/tharindu899/Tmx-theme/issues)

### Reporting Issues
When reporting an issue, include:
- Your OS (Termux/Ubuntu version)
- Error messages from the log file
- Steps to reproduce the problem
- Screenshots (if applicable)

### Contact
- 📧 Email: tprabath81@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/tharindu899/Tmx-theme/issues)

---

## 📝 Changelog

### Version 3.0.0 (Current)
- ✨ Complete rewrite with modular structure
- ✨ Interactive menu system
- ✨ Automatic backup before installation
- ✨ Better error handling and logging
- ✨ Support for both Termux and Ubuntu
- ✨ Improved installation speed
- ✨ Better documentation

### Version 2.0.0
- Added colorful theme option
- Improved Neovim configuration
- Better plugin management

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- **Created by**: [Tharindu Prabath](https://github.com/tharindu899)
- **Inspired by**: [T-Header by remo7777](https://github.com/remo7777/T-Header)
- **Powerlevel10k**: [romkatv](https://github.com/romkatv/powerlevel10k)
- **Oh My Zsh**: [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

---

## ⭐ Show Your Support

If you found this project helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 🔀 Forking and contributing

---

<div align="center">

**Made with ❤️ for the Terminal Community**

[⬆ Back to Top](#-tmx-theme-v30)

</div>
