#!/usr/bin/env bash

# Install font

font_url='https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip'
font_name=${font_url##*/} 
wget ${font_url} && unzip ${font_name} -d ~/.fonts && fc-cache -fv

# Install asdf

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
echo ". '$HOME/.asdf/asdf.sh'" >> "$HOME"/.bashrc
echo ". '$HOME/.asdf/completions/asdf.bash'" >> "$HOME"/.bashrc

# Install programs
## Vscode
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders

# Docker 
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker


# sudo apt-get install android-sdk -y
# echo 'export ANDROID_HOME="/usr/lib/android-sdk/"' >> "$HOME"/.bashrc
# echo "export PATH='${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/'" >> "$HOME"/.bashrc

# Fix cedilha (https://www.danielkossmann.com/pt/ajeitando-cedilha-errado-ubuntu-linux/)
sudo bash -c "echo 'GTK_IM_MODULE=cedilla' >> /etc/environment"
sudo bash -c "echo 'QT_IM_MODULE=cedilla' >> /etc/environment"

FILE="$HOME/.XCompose"
cat > "$FILE" <<- EOM
# UTF-8 (Unicode) compose sequences
# Overrides C acute with Ccedilla:
<dead_acute> <C> : "Ç" "Ccedilla"
<dead_acute> <c> : "ç" "ccedilla"
EOM

gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule': <'ibus'>}"

# Git config

git config --global user.name "Pedro Santos"
git config --global user.email pedrosantosdevelop@gmail.com

