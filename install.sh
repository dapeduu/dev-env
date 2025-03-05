#!/usr/bin/env bash

# Exit on any error
set -e

# Color codes for better logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Function to log errors
error_log() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

# Function to log warnings
warn_log() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Ensure script is run with bash
if [ -z "$BASH_VERSION" ]; then
    error_log "Please run this script with bash"
    exit 1
fi

# Check for required dependencies
check_dependencies() {
    local dependencies=("wget" "git" "curl" "unzip" "gpg")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error_log "$dep is not installed. Installing..."
            sudo apt-get update
            sudo apt-get install -y "$dep"
        fi
    done
}

# Install Nerd Fonts
install_nerd_fonts() {
    local font_url='https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip'
    local font_name=${font_url##*/}
    
    mkdir -p ~/.fonts
    wget -O "$HOME/.fonts/$font_name" "$font_url" || error_log "Failed to download JetBrainsMono font"
    unzip -o "$HOME/.fonts/$font_name" -d ~/.fonts || error_log "Failed to unzip font"
    fc-cache -fv
    log "JetBrainsMono Nerd Font installed"
}

# Install ZSH and set as default shell
install_zsh() {
    # Check if ZSH is installed
    if ! command -v zsh &> /dev/null; then
        warn_log "ZSH not found. Installing ZSH..."
        sudo apt-get update
        sudo apt-get install -y zsh
    fi

    # Create ZSH directory if it doesn't exist
    mkdir -p ~/.zsh

    # Clone ZSH extensions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions || warn_log "Failed to clone zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting || warn_log "Failed to clone zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions || warn_log "Failed to clone zsh-completions"

    # Copy .zshrc from script directory to home
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    if [ -f "$SCRIPT_DIR/.zshrc" ]; then
        cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
        log "Copied .zshrc from script directory"
    else
        warn_log ".zshrc not found in script directory"
    fi

    # Check if ZSH is already the default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        # Change default shell to ZSH
        # Use chsh with -s flag to set default shell
        chsh -s "$(which zsh)"
        
        log "ZSH set as default shell"
    else
        log "ZSH is already the default shell"
    fi
    
    log "ZSH installed"
}

# Install ASDF version manager
install_asdf() {
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0 || error_log "Failed to install ASDF"
    
    # Append to .bashrc and .zshrc if they exist
    for rc_file in "$HOME"/.bashrc "$HOME"/.zshrc; do
        if [ -f "$rc_file" ]; then
            grep -qxF ". '$HOME/.asdf/asdf.sh'" "$rc_file" || echo ". '$HOME/.asdf/asdf.sh'" >> "$rc_file"
            grep -qxF ". '$HOME/.asdf/completions/asdf.bash'" "$rc_file" || echo ". '$HOME/.asdf/completions/asdf.bash'" >> "$rc_file"
        fi
    done
    
    log "ASDF version manager installed"
}

# Install VSCode
install_vscode() {
    # Import Microsoft GPG key
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    rm -f packages.microsoft.gpg

    # Add VSCode repository
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

    # Install VSCode
    sudo apt-get update
    sudo apt-get install -y apt-transport-https code
    
    log "VSCode installed"
}

install_starship() {
    curl -sS https://starship.rs/install.sh | sh
}

# Install Docker
install_docker() {
    # Remove existing Docker packages
    sudo apt-get remove -y docker docker-engine docker.io containerd runc

    # Setup Docker's official GPG key
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to Docker group
    sudo groupadd docker 2>/dev/null || true  # Ignore error if group exists
    sudo usermod -aG docker "$USER"
    newgrp docker

    log "Docker installed"
}

# Fix cedilha input method
fix_cedilha() {
    # Add to environment
    sudo bash -c "echo 'GTK_IM_MODULE=cedilla' >> /etc/environment"
    sudo bash -c "echo 'QT_IM_MODULE=cedilla' >> /etc/environment"

    # Create .XCompose file
    FILE="$HOME/.XCompose"
    cat > "$FILE" <<- EOM
# UTF-8 (Unicode) compose sequences
# Overrides C acute with Ccedilla:
<dead_acute> <C> : "Ç" "Ccedilla"
<dead_acute> <c> : "ç" "ccedilla"
EOM

    # Set ibus module
    gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule': <'ibus'>}"
    
    log "Cedilha input method fixed"
}

# Configure Git
configure_git() {
    git config --global user.name "Pedro Santos"
    git config --global user.email pedrosantosdevelop@gmail.com
    
    log "Git configured"
}

# Main setup function
main() {
    echo "Starting Development Environment Setup..."
    
    # Check and install dependencies
    check_dependencies
    
    # Run installation functions
    install_starship
    install_nerd_fonts
    install_zsh_extensions
    install_asdf
    install_vscode
    install_docker
    fix_cedilha
    configure_git
    
    echo -e "${GREEN}Development Environment Setup Complete! Log out and in to finish the setup.${NC}"
}

# Run the main setup function
main
