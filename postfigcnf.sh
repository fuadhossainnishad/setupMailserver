#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges. Switching to root privileges using sudo..."
  sudo bash "$0" "$@"
  exit
fi

# Function to check if Postfix is installed
check_postfix_installed() {
  dpkg -l | grep -qw postfix
}

# Install Postfix if not installed
if check_postfix_installed; then
  echo "Postfix is already installed."
else
  echo "Postfix is not installed."
  echo "Reminder: after installing Postfix click on 'right click of mouse',then select 'Internet Site'"
  echo "In 'System Mail Name' field write system mail name(Example:oslab.com)"
  echo "Installing Postfix..."
  while true; do
  read -p "Are you ready now? (y/n): " choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    apt update -y
    apt install -y postfix
    break
  else
    echo "The program cannot proceed without installing postfix file."
    echo "Please type 'y' to continue."
  fi
  done
  if [ $? -eq 0 ]; then
    echo "Postfix installation completed successfully."
    systemctl restart postfix
    echo "Postfix has been configured successfully with the mail name"
  else
    echo "Failed to install Postfix. Please check your network or package manager configuration."
    exit 1
  fi
fi


# Check postfix status in the background and then stop it after 10 seconds
echo "Checking Postfix status..."
sudo systemctl status postfix &


# Configure the home mailbox location to Maildir
sudo postconf "home_mailbox = Maildir/"

# Check the Postfix configuration
postconf -n

# Indicate that the script has finished successfully
echo "Postfix configuration has been updated with 'home_mailbox = Maildir/'."
