#!/bin/bash

# Install dovecot
sudo apt update
sudo apt install dovecot-core dovecot-imapd dovecot-pop3d

# Check dovecot status
sudo systemctl status dovecot

# Reload
sudo systemctl reload postfix
sudo systemctl reload dovecot


echo "Please comment-out this line: 'mail_location = maildir:~/Maildir'"
echo "Also comment other file location."



# Check the configuration
doveconf -n

# Reload Dovecot to apply changes
sudo systemctl reload dovecot
echo "Configuration completed."

read -p "Enter Real Name: " realname
read -p "Enter username: " username
read -p "Enter password: " password

# Check if the username is not empty and valid
if [[ -z "$username" ]]; then
    echo "Username cannot be empty. Please enter a valid username."
    exit 1
fi

# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User '$username' already exists. Please choose a different username."
    exit 1
fi

# Navigate to /etc/skel and create Maildir structure if it doesn't exist
sudo bash -c "
cd /etc/skel || { echo 'Failed to navigate to /etc/skel'; exit 1; }
if [ ! -d 'Maildir' ]; then
    mkdir -p Maildir/current Maildir/new Maildir/tmp Maildir/spam
    echo 'Maildir structure created.'
    echo 'directory list-'
    ls -la Maildir/
else
    echo 'Maildir structure already exists.'
fi
"

# Install Mutt if not already installed
if ! command -v mutt &> /dev/null; then
    sudo apt install -y mutt
    echo "Mutt installed."
else
    echo "Mutt is already installed."
fi

# Create .mutt directory and check if it exists
if [ ! -d "/etc/skel/.mutt" ]; then
    sudo mkdir /etc/skel/.mutt
    ls -la
    echo ".mutt directory created."
else
    echo ".mutt directory already exists."
fi

# Create muttrc file and write the configuration into it
MUTTRC_PATH="/etc/skel/.mutt/muttrc"
if [ ! -f "$MUTTRC_PATH" ]; then
    sudo touch "$MUTTRC_PATH"
    echo "muttrc file created."
fi

# Write configuration to muttrc
sudo tee "$MUTTRC_PATH" > /dev/null <<EOL
set imap_user = $username
set imap_pass = $password

set folder = imaps://mailserver
set spoolfile = +INBOX

set realname = $realname
set from = "\$imap_user"
set use_from = yes

set sort=reverse-date

mailboxes = INBOX

set timeout=1

set sidebar_visible = yes

source ~/.mutt/mutt_colors
EOL

echo "muttrc configuration written."

# Create mutt_colors file and write the configuration into it
MUTTCOLORS_PATH="/etc/skel/.mutt/mutt_colors"
if [ ! -f "$MUTTCOLORS_PATH" ]; then
    sudo touch "$MUTTCOLORS_PATH"
    echo "muttrc file created."
fi
sudo tee "$MUTTCOLORS_PATH" > /dev/null <<EOL
# Colours for items in the index
color index brightcyan black ~N
# Hmm, don't like this.
# color index brightgreen black "~N (~x byers.world)|(~x byers.x)|(~x langly.levallois123.axialys.net)|(~x the.earth.li)"
color index brightyellow black ~F
color index black green ~T
color index brightred black ~D
mono index bold ~N
mono index bold ~F
mono index bold ~T
mono index bold ~D

# Highlights inside the body of a message.
  read -p "Are you ready now? (y/n): " choice
# URLs
color body brightgreen black "(http|ftp|news|telnet|finger)://[^ \"\t\r\n]*"
color body brightgreen black "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
mono body bold "(http|ftp|news|telnet|finger)://[^ \"\t\r\n]*"
mono body bold "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"

# email addresses
color body brightgreen black "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
mono body bold "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"

# header
color header green black "^from:"
color header green black "^to:"
color header green black "^cc:"
color header green black "^date:"
color header yellow black "^newsgroups:"
color header yellow black "^reply-to:"
# color header brightcyan black "^subject:"
color header yellow black "^subject:"
color header red black "^x-spam-rule:"
color header green black "^x-mailer:"
color header yellow black "^message-id:"
color header yellow black "^Organization:"
color header yellow black "^Organisation:"
color header yellow black "^User-Agent:"
color header yellow black "^message-id: .*pine"
color header yellow black "^X-Fnord:"
color header yellow black "^X-WebTV-Stationery:"
color header yellow black "^X-Message-Flag:"
color header yellow black "^X-Spam-Status:"
color header yellow black "^X-SpamProbe:"
color header red black "^X-SpamProbe: SPAM"

# Coloring quoted text - coloring the first 7 levels:
color quoted cyan black
color quoted1 yellow black
color quoted2 red black
color quoted3 green black
color quoted4 cyan black
color quoted5 yellow black
color quoted6 red black
color quoted7 green black


# Default color definitions
#color hdrdefault white green
color signature brightmagenta black
color indicator black cyan
color attachment black green
color error red black
color message white black
color search brightwhite magenta
# color status brightyellow blue
color status blue black
color tree brightblue black
color normal white black
color tilde green black
color bold brightyellow black
color underline magenta black
color markers brightcyan black

# Colour definitions when on a mono screen
mono bold bold
mono underline underline
mono indicator reverse
EOL

echo "muttrc configuration written."

sudo cd..

# Return to /etc/skel and set permissions
sudo chmod 700 -R /etc/skel/
echo "Permissions set to 700 for /etc/skel and its subdirectories."

echo "All configurations and permissions have been completed successfully."



# Create the user and copy the contents from /etc/skel/
sudo adduser --gecos "" "$username"

# Inform the user of successful account creation
echo "User '$username' has been created successfully with home directory initialized from /etc/skel/."

# Optional: Set a password for the new user (uncomment if needed)
# echo "Please set a password for the new user:"
# sudo passwd "$username"

echo "User creation and initialization are complete."

# Switch to the new user and launch Mutt
echo "Switching to user '$username' and opening Mutt..."
sudo su - "$username" -c "mutt"
