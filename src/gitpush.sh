#!/data/data/com.termux/files/usr/bin/bash

# === Colors ===
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RESET="\033[0m"

clear
echo -e "${CYAN}================================================="
echo -e "${GREEN}        GitHub File/Project Uploader - Termux"
echo -e "${CYAN}=================================================${RESET}"
echo ""

# === GitHub Credentials ===
GITHUB_USERNAME="username github"
GITHUB_EMAIL="your email enter"
ACCESS_TOKEN="$GITHUB_TOKEN"  # Set: export GITHUB_TOKEN=your_token

if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}Error: GitHub token not set. Use 'export GITHUB_TOKEN=your_token'${RESET}"
    exit 1
fi

# === User Inputs ===
read -p "Enter the path to your file or project folder: " INPUT_PATH
INPUT_PATH="${INPUT_PATH/#\~/$HOME}"

if [ ! -e "$INPUT_PATH" ]; then
    echo -e "${RED}Error: File or directory not found.${RESET}"
    exit 1
fi

read -p "Enter the name of your GitHub repository: " REPO_NAME
read -p "Enter a description for your repository: " REPO_DESCRIPTION
echo -e "\nChoose repository visibility:\n1) Public\n2) Private"
read -p "Enter 1 or 2: " VISIBILITY

if [ "$VISIBILITY" = "2" ]; then
    PRIVATE=true
    echo -e "${YELLOW}Creating private repository...${RESET}"
else
    PRIVATE=false
    echo -e "${YELLOW}Creating public repository...${RESET}"
fi

TMP_JSON=$(mktemp)
CREATE_RESPONSE=$(curl -s -w "%{http_code}" -o "$TMP_JSON" -u "$GITHUB_USERNAME:$ACCESS_TOKEN" https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\", \"description\":\"$REPO_DESCRIPTION\", \"private\":$PRIVATE}")

if [ "$CREATE_RESPONSE" = "201" ]; then
    echo -e "${GREEN}Repository created successfully.${RESET}"
elif grep -q "name already exists" "$TMP_JSON"; then
    echo -e "${YELLOW}Repository already exists. Proceeding to update it...${RESET}"
else
    echo -e "${RED}Failed to create repository. See details below:${RESET}"
    cat "$TMP_JSON"
    rm "$TMP_JSON"
    exit 1
fi

rm "$TMP_JSON"

# === Branch Name ===
read -p "Enter the branch name to push to (leave empty for 'master'): " BRANCH_NAME
BRANCH_NAME=${BRANCH_NAME:-master}

# === Clone Repo ===
WORK_DIR=$(mktemp -d)
REPO_URL="https://$GITHUB_USERNAME:$ACCESS_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git"

echo -e "${CYAN}Cloning repository...${RESET}"
git clone -b "$BRANCH_NAME" "$REPO_URL" "$WORK_DIR" > /dev/null 2>&1 || {
    echo -e "${YELLOW}Branch '$BRANCH_NAME' not found. Creating new one...${RESET}"
    git clone "$REPO_URL" "$WORK_DIR" > /dev/null 2>&1
    cd "$WORK_DIR" && git checkout -b "$BRANCH_NAME"
}

cd "$WORK_DIR" || exit 1

# === Copy content ===
if [ -d "$INPUT_PATH" ]; then
    cp -r "$INPUT_PATH"/* "$WORK_DIR"/
else
    cp "$INPUT_PATH" "$WORK_DIR"/
fi

# === Git commit ===
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"
git add . > /dev/null

read -p "Enter a commit message (or leave empty for 'Update via script'): " COMMIT_MESSAGE
COMMIT_MESSAGE=${COMMIT_MESSAGE:-Update via script}

git commit -m "$COMMIT_MESSAGE" > /dev/null 2>&1 || echo -e "${YELLOW}Nothing new to commit.${RESET}"

# === Push ===
echo -e "${CYAN}Pushing to GitHub...${RESET}"
git push -u origin "$BRANCH_NAME" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully pushed to GitHub.${RESET}"
    echo -e "URL: ${CYAN}https://github.com/$GITHUB_USERNAME/$REPO_NAME/tree/$BRANCH_NAME${RESET}"
else
    echo -e "${RED}Failed to push files. Check branch or token setup.${RESET}"
fi

# === Cleanup ===
rm -rf "$WORK_DIR"

# === Credit ===
echo -e "\n${PURPLE}Script by Tharindu Prabath - GitHub Project Uploader${RESET}"
