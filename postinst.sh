#!/bin/bash

echo "Post install and configuration script running now"

# dconf dump /org/cinnamon/ > ~/dconf-cinnamon.bck.dconf

echo "SET: new window placement mode to centre screen"
dconf write /org/cinnamon/muffin/placement-mode "'center'"

echo "Setting permissions"
chown -R root:root /usr/share/cinnamon-background-properties
chown -R root:root /usr/share/backgrounds/linuxmint-catppuccin
chmod -R 775 /usr/share/cinnamon-background-properties
chmod -R 775 /usr/share/backgrounds/linuxmint-catppuccin

# Ask for valid username
echo "The installer needs to set configurations in your user directory."
while true; do
    read -p "Please enter your username to continue: " USERNAME

    # Check if input is not empty
    if [[ -z "$USERNAME" ]]; then
        echo "Username cannot be empty. Please try again."
        continue
    fi

    # Check if user exists
    if id "$USERNAME" &>/dev/null; then
        echo "User '$USERNAME' exists. Continuing installation..."
        break
    else
        echo "User '$USERNAME' does not exist. Please try again."
    fi
done

# Proceed with user-specific operations
cp -r /tmp/.cinnamon/ /home/$USERNAME/
cp -r /tmp/.local/ /home/$USERNAME/
cp -r /tmp/cinnamon-config/ /home/$USERNAME/

chown -R $USERNAME:$USERNAME /home/$USERNAME/.cinnamon
chown -R $USERNAME:$USERNAME /home/$USERNAME/.local
chown -R $USERNAME:$USERNAME /home/$USERNAME/cinnamon-config

# Load dconf settings as the user
sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
    dconf load /org/cinnamon/ < /home/$USERNAME/cinnamon-config/cinnamon-catppcn.conf

# Clean up temp files
rm -rf /tmp/.cinnamon
rm -rf /tmp/.local
rm -rf /tmp/cinnamon-config
