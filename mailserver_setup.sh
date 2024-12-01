#!/bin/bash

# Ensure root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges. Switching to root privileges using sudo..."
  sudo bash "$0" "$@"
  exit
fi

# Function to run a script and handle errors
run_script() {
  local script_name=$1
  echo "Running $script_name..."
  ./$script_name
  if [ $? -ne 0 ]; then
    echo "$script_name encountered an error. Exiting."
    exit 1
  fi
}

# Run scripts sequentially
run_script "mailserver.sh"
run_script "host.sh"
run_script "postfigcnf.sh"
run_script "dovecotcnf.sh"

