#!/bin/bash
set -e

# Define a few soft colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set Root as the owner of the current working directory
sudo chown -R root:root .

# Include the gh_copilot_cli_on_dev_container.sh script to install the GitHub Copilot CLI extension for GitHub CLI
. $REPO_ROOT/gh_copilot_cli_on_dev_container.sh

echo -e "${GREEN}Done!${NC}"
echo -e "${YELLOW}If the alias ?? is not working, please restart your terminal session${NC}"