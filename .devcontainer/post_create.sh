#!/bin/bash
set -e

# Define a few soft colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set Root as the owner of the current working directory
sudo chown -R root:root .

# Check if we have a .config/gh/config.yml file and if it contains a token
if [ -f ~/.config/gh/config.yml ] || grep -q token ~/.config/gh/config.yml; then
    echo "Found GitHub CLI token in ~/.config/gh/config.yml"
    echo "Installing GitHub Copilot extension for CLI"
    gh extension install github/gh-copilot    

    # Add permanent aliases
    echo -e "${BLUE}Adding permanent aliases for GitHub Copilot${NC}"
    echo -e "Setting alias ${GREEN}copilot${NC} for ${GREEN}gh copilot${NC}"
    alias copilot="gh copilot"; echo "alias copilot='gh copilot'" >> /etc/bash.bashrc
    echo -e "Setting alias ${GREEN}?sh${NC} for ${GREEN}gh copilot suggest -t shell${NC}"
    alias ?sh="gh copilot suggest -t shell"; echo "alias ?sh='gh copilot suggest -t shell'" >> /etc/bash.bashrc
    echo -e "Setting alias ${GREEN}?gh${NC} for ${GREEN}gh copilot suggest -t gh${NC}"
    alias ?gh="gh copilot suggest -t gh"; echo "alias ?gh='gh copilot suggest -t gh'" >> /etc/bash.bashrc
    echo -e "Setting alias ${GREEN}?git${NC} for ${GREEN}gh copilot suggest -t git${NC}"
    alias ?git="gh copilot suggest -t git"; echo "alias ?git='gh copilot suggest -t git'" >> /etc/bash.bashrc

    echo -e "Setting alias ${GREEN}??sh${NC} for ${GREEN}gh copilot explain -t shell${NC}"
    alias ??sh="gh copilot explain -t shell"; echo "alias ??sh='gh copilot explain -t shell'" >> /etc/bash.bashrc
    echo -e "Setting alias ${GREEN}??gh${NC} for ${GREEN}gh copilot explain -t gh${NC}"
    alias ??gh="gh copilot explain -t gh"; echo "alias ??gh='gh copilot explain -t gh'" >> /etc/bash.bashrc
    echo -e "Setting alias ${GREEN}??git${NC} for ${GREEN}gh copilot explain -t git${NC}"
    alias ??git="gh copilot explain -t git"; echo "alias ??git='gh copilot explain -t git'" >> /etc/bash.bashrc
else
    echo "No GitHub CLI token found in ~/.config/gh/config.yml"
    echo "Skipping installation of GitHub Copilot extension for CLI"
    echo "If you want to use GitHub Copilot, please run 'gh auth login' to login to GitHub CLI"
    echo "Then run 'gh extension install github/gh-copilot' to install the GitHub Copilot extension for CLI"
fi


echo -e "${GREEN}Done!${NC}"
echo -e "${YELLOW}If the alias ?? is not working, please restart your terminal session${NC}"