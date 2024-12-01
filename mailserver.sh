#!/bin/bash
# mailserver.sh

sudo apt-get update
# Prompt for hostname
read -p "Set a relative name matching with the project for example:(mail): " hostname

sudo hostnamectl set-hostname $hostname

# Confirm hostname was set
echo "Hostname has been set to: $(hostname)"

# Open a new terminal
if command -v gnome-terminal &> /dev/null; then
  gnome-terminal &
else
  echo "gnome-terminal not found. Please open a new terminal manually."
fi

