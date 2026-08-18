# 🎨 Termux Theme

<div align="center">
  <img src="https://img.shields.io/badge/Version-4.1.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Platform-Termux-orange" alt="Platform">
</div>

<p align="center">
  <img src="https://github.com/tharindu899/Tmx-theme/blob/master/src/img/tmx5.jpg" alt="tmx5" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Termux_Theme_Customizer-2D3436?style=for-the-badge&logo=android&logoColor=white&labelColor=2D3436" />
</p>

---

## ✨ Features

- 🎨 **Dual theme options** – Black (classic) or Color (rainbow)
- 🖥️ **Interactive TUI installer** with live log & animated progress bars
- 🌐 Pre‑installation network check
- ⚡ **Powerlevel10k** Zsh prompt with custom fonts
- 📝 Pre‑configured **Neovim / AstroNvim** IDE
- 🐚 **Oh My Zsh** + curated plugin set
- 🗑️ **One‑click uninstall**
- 📦 Automatic dependency resolver
- 🔐 **Optional GitHub dual‑account setup** – toggle on/off from menu (default: enabled)
- ❗ Failed‑task error log at `~/skip_errors.log`
- 🧩 **Developer‑friendly aliases** and tools
- 🔁 Safe re‑install / update support

---

## 📂 Directory Structure

```

~/Tmx-theme/
├── 📜 install.sh              # Main installer (v4.1)
├── 📜 install_v1.sh           # Alternative installer (v4.0 TUI)
├── 📁 src/                    # Assets & configs
│   ├── 🎨 font.ttf            # Nerd Font
│   ├── ⚙️  termux.properties
│   ├── 🖌️  colors.properties
│   ├── 🐧 .zshrc
│   ├── 🖼️  .banner.sh
│   ├── 🎭 .draw
│   ├── ✏️  .draw.sh
│   ├── 📜 zshrc
│   └── 🖋️  ASCII-Shadow.flf
├── 📁 black/                  # Dark theme package
│   └── ⚡ .p10k.zsh
├── 📁 color/                  # Colorful theme package
│   └── ⚡ .p10k.zsh
└── 📁 scripts/                # Helper scripts
└── 🔐 github‑dual‑account.sh   # Shared GitHub setup logic

```

---

## 📥 Installation

### ⚙️ Step 1 — Prerequisites (run this first on a fresh Termux)

The installer uses `tput` for its TUI, so install these packages **before** cloning:

```bash
pkg update -y && pkg install git bash ncurses-utils -y
```

Package Why it's needed
git Clone the repo
bash Run the installer
ncurses-utils Provides tput (required for TUI)

Everything else (Zsh, Neovim, Oh My Zsh, plugins, fonts…) is installed automatically.

---

🚀 Step 2 — Clone & Run

```bash
git clone https://github.com/tharindu899/Tmx-theme.git ~/Tmx-theme && \
cd ~/Tmx-theme && \
chmod +x install.sh && \
./install.sh
```

Alternative installer (v1)

If you prefer the older V1 installer:

```bash
chmod +x install_v1.sh && ./install_v1.sh
```

Both installers share the same GitHub dual‑account script (scripts/github‑dual‑account.sh), so updates are centralised.

---

🖥️ Installer Menu

Both installers present a full‑screen menu with five options:

Option Action
1 Install Black Theme (classic dark prompt)
2 Install Color Theme (rainbow powerline prompt)
3 Uninstall — removes all theme files
4 Toggle GitHub dual‑account setup – shows [ON] / [OFF] (default: ON)
5 Exit

The installer checks your internet connection first, then runs all steps with live scrolling log and real‑time progress bars.
GitHub dual‑account setup is only executed if option 4 is toggled ON.

---

🖼️ Theme Previews

Color Theme Black Theme
<img src="https://i.imgur.com/84qJ3vP.jpeg" width="300"> <img src="https://i.imgur.com/FUwyvU8.jpeg" width="300">

---

📋 File Locations

Config File Destination
src/font.ttf ~/.termux/font.ttf
src/.zshrc ~/.zshrc
src/termux.properties ~/.termux/termux.properties
src/colors.properties ~/.termux/colors.properties
src/.banner.sh ~/.banner.sh
src/.draw / src/.draw.sh ~/.draw / ~/.draw.sh
src/ASCII-Shadow.flf $PREFIX/share/figlet/
src/zshrc $PREFIX/etc/zshrc
{black,color}/.p10k.zsh ~/.p10k.zsh

---

🛠️ Installed Tools

Category Tools
Core Zsh, Git, Python, wget, curl
CLI Tools lsd, logo‑ls, bat, ripgrep, fd, fzf, figlet, lolcat, ncurses‑utils
Development Neovim, Lua, lua‑language‑server, lazygit, luarocks, stylua
Build & Extras build‑essential, clang, zig, ccls, rust‑analyzer, yarn, jq‑lsp
Shell Oh My Zsh, Powerlevel10k, zsh‑syntax‑highlighting, zsh‑autosuggestions
Utilities termux‑api, gdu, gdb, gh (GitHub CLI), zip
Neovim neovim pip/npm/gem providers, AstroNvim (tharindu899/tmx‑nvim)
GitHub (optional) Dual‑account SSH configuration script

---

🔌 Oh My Zsh Plugins

copypath · dircycle · extract · frontend‑search · git · git‑auto‑fetch · git‑flow‑completion · gitfast · git‑prompt · ionic · pre‑commit · safe‑paste · web‑search · zsh‑completions · zsh‑history‑substring‑search · zsh‑syntax‑highlighting · zsh‑autosuggestions

---

🐙 GitHub Dual‑Account System

Tmx‑theme includes a dual‑account setup for GitHub. It configures two separate GitHub CLI profiles, each with its own SSH key and credentials.

· Account 1 – tharindu899 (alias: gh1)
· Account 2 – cineflow‑web (alias: gh2)

The system automatically selects the correct account based on the repository owner, so you can just git push normally.

🔐 Login to GitHub Accounts

Login to account 1:

```bash
GH_CONFIG_DIR=$HOME/.config/gh-account1 gh auth login
```

Login to account 2:

```bash
GH_CONFIG_DIR=$HOME/.config/gh-account2 gh auth login
```

🔎 Check GitHub Login Status

Account 1:

```bash
gh1 auth status
```

Account 2:

```bash
gh2 auth status
```

You should see:

· gh1 → tharindu899
· gh2 → cineflow-web

👤 Using GitHub Accounts Manually

Account 1:

```bash
gh1
```

Example: gh1 repo list

Account 2:

```bash
gh2
```

Example: gh2 repo list

📦 Clone Repositories

Account 1:

```bash
gh1 repo clone tharindu899/REPOSITORY
```

Account 2:

```bash
gh2 repo clone cineflow-web/REPOSITORY
```

🚀 Automatic Git Push

You normally do not need to use gh1push or gh2push. Git automatically detects the repository owner:

· Repository owned by tharindu899 → uses gh1
· Repository owned by cineflow-web → uses gh2

Just use:

```bash
git push
```

🧪 Check Repository Remote

```bash
git remote -v
```

Example output for Account 1:

```
origin  https://github.com/tharindu899/Tmx-theme.git
```

Example for Account 2:

```
origin  https://github.com/cineflow-web/CineFlow_Watch.git
```

🔄 Change Repository Remote

For Account 1:

```bash
git remote set-url origin https://github.com/tharindu899/REPOSITORY.git
```

For Account 2:

```bash
git remote set-url origin https://github.com/cineflow-web/REPOSITORY.git
```

Then verify with git remote -v.

🌿 Git Branch Commands

Show current branch:

```bash
git branch --show-current
```

Show all branches:

```bash
git branch -a
```

Create a new branch:

```bash
git checkout -b CineFlow
```

or

```bash
git switch -c CineFlow
```

Rename current branch:

```bash
git branch -M CineFlow
```

Push and set upstream:

```bash
git push -u origin CineFlow
```

After upstream is set, git push works normally.

📤 Git Push Workflow

```bash
git status
git add .
git commit -m "Update"
git push
```

The correct GitHub account is selected automatically.

📥 Git Pull

```bash
git pull
```

🔄 Git Fetch

```bash
git fetch
```

📊 Git Status

```bash
git status
```

📝 Git Log

```bash
git log --oneline --decorate --graph --all
```

↩️ Undo Last Commit

Keep changes:

```bash
git reset --soft HEAD~1
```

Discard changes:

```bash
git reset --hard HEAD~1
```

⚠️ Be careful with --hard.

🧹 Git Cleanup

Remove untracked files:

```bash
git clean -fd
```

⚠️ Permanently deletes untracked files.

🔧 Git Configuration

Show global configuration:

```bash
git config --global --list
```

Show repository configuration:

```bash
git config --local --list
```

Show where configuration comes from:

```bash
git config --show-origin --show-scope --get-regexp 'credential|url'
```

🔐 GitHub Credential Configuration

The dual‑account setup creates:

· ~/.gitconfig-gh1
· ~/.gitconfig-gh2
· ~/.config/gh-account1/
· ~/.config/gh-account2/

Check contents:

```bash
cat ~/.gitconfig-gh1
cat ~/.gitconfig-gh2
```

🧪 Test Which GitHub Account Git Uses

Inside a repository:

```bash
git credential fill <<EOF
protocol=https
host=github.com
path=$(git remote get-url origin | sed -E 's#https://github.com/##; s#\.git$##')
EOF
```

The output should contain username=tharindu899 for a tharindu899 repository, or username=cineflow-web for a cineflow-web repository.

⚠️ Never share the password= value.

🛠️ Fix GitHub 403 Error

If you see Permission to ... denied to tharindu899:

1. Check remote:
   ```bash
   git remote -v
   ```
2. Check GitHub CLI status:
   ```bash
   gh1 auth status
   gh2 auth status
   ```
3. Check Git configuration:
   ```bash
   git config --show-origin --show-scope --get-regexp 'credential|url'
   ```
4. Remove repository‑specific credential helper:
   ```bash
   git config --local --unset-all credential.helper 2>/dev/null
   ```
5. Retry:
   ```bash
   git push
   ```

🧹 Remove Old GitHub Credential

For the current repository:

```bash
printf "protocol=https\nhost=github.com\n\n" | git credential reject
```

Then retry git push.

🐳 GitHub CLI Repository Commands

Create a public repository with Account 1:

```bash
gh1 repo create tharindu899/REPOSITORY --public
```

Create a private repository:

```bash
gh1 repo create tharindu899/REPOSITORY --private
```

Create with Account 2:

```bash
gh2 repo create cineflow-web/REPOSITORY --public
```

View repository:

```bash
gh1 repo view tharindu899/REPOSITORY
gh2 repo view cineflow-web/REPOSITORY
```

🔗 GitHub Remote Setup

For a new Account 1 repository:

```bash
git remote add origin https://github.com/tharindu899/REPOSITORY.git
```

For Account 2:

```bash
git remote add origin https://github.com/cineflow-web/REPOSITORY.git
```

Then push:

```bash
git push -u origin HEAD
```

---

🧑‍💻 LazyVim & Lazygit

The automatic GitHub account system works seamlessly with LazyVim and Lazygit. You never need to use gh1push or gh2push – just use normal Git commands.

In LazyVim:

· Git → Commit
· Git → Push
· or use :!git push

In Lazygit:

· Start with lazygit
· Use Commit, Push, Pull normally

The correct account is selected automatically based on the repository owner.

---

🐚 Zsh Aliases

After installation, reload Zsh:

```bash
source ~/.zshrc
```

Available aliases:

· gh1 – GitHub account 1 (tharindu899)
· gh2 – GitHub account 2 (cineflow-web)

Check aliases:

```bash
alias gh1
alias gh2
```

---

🔄 Update Tmx‑theme

```bash
cd ~/Tmx-theme
git pull
./install.sh   # re‑run if needed
```

---

🆘 Troubleshooting

gh: command not found

Install GitHub CLI:

```bash
pkg update && pkg install gh -y
```

git: command not found

```bash
pkg install git -y
```

GitHub returns 403

Check:

```bash
gh1 auth status
gh2 auth status
git remote -v
```

Make sure the repository owner is correct.

Upstream gone

```bash
git branch -vv
git push -u origin HEAD
```

Push goes to wrong account

```bash
git config --show-origin --show-scope --get-regexp 'credential|url'
git remote -v
```

For cineflow‑web repositories, the remote must contain github.com/cineflow-web/; for tharindu899 repositories, github.com/tharindu899/.

---

🔒 Security

· Never put GitHub tokens directly in .git/config or in remote URLs.
· Do not share tokens like gho_....
· GitHub authentication is handled by GitHub CLI; credentials are stored securely in ~/.config/gh-account*.

---

📁 Important Files

File / Directory Purpose
~/.config/gh-account1 GitHub CLI config for account 1
~/.config/gh-account2 GitHub CLI config for account 2
~/.gitconfig Main Git configuration
~/.gitconfig-gh1 Git credential helper for tharindu899
~/.gitconfig-gh2 Git credential helper for cineflow-web
~/Tmx-theme/scripts/github-dual-account.sh Automatic GitHub account setup script

---

🎯 Quick Command Reference

Task Command
Account 1 status gh1 auth status
Account 2 status gh2 auth status
Account 1 repos gh1 repo list
Account 2 repos gh2 repo list
Clone account 1 repo gh1 repo clone USER/REPO
Clone account 2 repo gh2 repo clone USER/REPO
Git status git status
Git add git add .
Git commit git commit -m "Update"
Git push git push
Git pull git pull
Git fetch git fetch
Current branch git branch --show-current
Remote git remote -v
Branch list git branch -a
Git log git log --oneline --graph --all
Reload Zsh source ~/.zshrc
Open Lazygit lazygit

---

🚀 One‑Line Setup

```bash
git clone https://github.com/tharindu899/Tmx-theme.git && cd Tmx-theme && chmod +x install.sh && ./install.sh
```

---

👤 GitHub Accounts Overview

```
╭─────────────────────────────────────╮
│ TMX‑THEME GITHUB                    │
├─────────────────────────────────────┤
│                                     │
│ 👤 tharindu899                      │
│    └── gh1                          │
│                                     │
│ 🎬 cineflow‑web                     │
│    └── gh2                          │
│                                     │
├─────────────────────────────────────┤
│ Automatic account selection         │
│ Git • LazyVim • Lazygit             │
╰─────────────────────────────────────╯
```

---

❓ FAQ

How do I switch themes?

```bash
bash ~/Tmx‑theme/install.sh   # choose 1 or 2 from the menu
```

Where are configs stored?

```
~/.termux/
~/.zshrc
~/.p10k.zsh
~/.config/nvim/
```

Something failed – where is the error log?

```bash
cat ~/skip_errors.log
```

How do I start the new shell after install?

```bash
zsh
```

The installer also sets Zsh as your default shell via chsh.

How do I re‑run the GitHub setup later?

```bash
bash ~/Tmx‑theme/scripts/github‑dual‑account.sh
```

---

🗑️ Uninstall

From the installer menu:

```bash
bash ~/Tmx‑theme/install.sh   # choose option 3
```

Manual removal:

```bash
rm -rf ~/.termux ~/.zsh* ~/.oh‑my‑zsh ~/.config/nvim ~/.banner.sh ~/.draw ~/.draw.sh ~/.p10k.zsh
termux‑reload‑settings
```

---

📌 Important Notes

1. Allow Termux storage permissions before installing.
2. Restart Termux after installation completes.
3. First launch may take 2–3 minutes (plugin compilation).
4. Installation requires an active internet connection.
5. The installer keeps a log of all failed tasks in ~/skip_errors.log.

---

✨ Pro Tip: Press Ctrl + T to open a new Termux session instantly!

💻 Crafted with ❤️ by Tharindu899

🔗 Credits: Inspired by the amazing work of remo7777 ⭐

📬 Need Help? Reach out: tprabath81@gmail.com
---