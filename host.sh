#!/bin/bash
# host.sh

# Check if ifconfig is installed
if ! command -v ifconfig &> /dev/null; then
  echo "ifconfig not found. Installing net-tools..."
  sudo apt-get update
  sudo apt-get install -y net-tools
fi

# Extract the primary IP address
IP=$(ifconfig | grep -A 1 'inet ' | awk '/inet / {print $2}' | head -n 1)

# Check if IP was found
if [ -z "$IP" ]; then
  echo "Could not extract IP address. Exiting."
  exit 1
fi

# Get hostname and domain name
HOSTNAME="mail"
DOMAIN=$(hostname -d 2>/dev/null || echo "mail")

# Display details
echo "Your system IP address is: $IP"
echo "Your System hostname: $HOSTNAME"
echo "Your System domain name: $DOMAIN"
echo "Your fully qualified domain name: $HOSTNAME.$DOMAIN"
echo "Now copy this line and paste it in the /etc/hosts file:"
echo "$IP $HOSTNAME.$DOMAIN $HOSTNAME"

# Loop until the user gives permission to open /etc/hosts
while true; do
  read -p "Do you want to open the /etc/hosts file for editing now? (y/n): " choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    sudo nano /etc/hosts
    echo "You have successfully edited the /etc/hosts file."
    break
  else
    echo "The program cannot proceed without editing the /etc/hosts file."
    echo "Please type 'y' to open the file and continue."
  fi
done

