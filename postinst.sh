#!/bin/bash

echo "Post install and configuration script running now"

#dconf dump /org/cinnamon/ > ~/dconf-cinnamon.bck.dconf

echo "SET: new window placement mode to centre screen"
dconf write /org/cinnamon/muffin/placement-mode "'center'"

echo "Setting permissions"

chown -R root:root /usr/share/cinnamon-background-properties
chown -R root:root /usr/share/backgrounds/linuxmint-catppuccin

chmod -R 775 /usr/share/cinnamon-background-properties
chmod -R 775 /usr/share/backgrounds/linuxmint-catppuccin

echo "The installer needs to set configurations in your user directory, please enter your username to continue"
read USERNAME

cp -r /tmp/.cinnamon/ /home/$USERNAME
cp -r /tmp/.local/ /home/$USERNAME
cp -r /tmp/cinnamon-config/ /home/$USERNAME

chown -R $USERNAME:$USERNAME /home/$USERNAME/.cinnamon
chown -R $USERNAME:$USERNAME /home/$USERNAME/.local
chown -R $USERNAME:$USERNAME /home/$USERNAME/cinnamon-config

# shellcheck disable=SC2046
sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" dconf load /org/cinnamon/ < /home/$USERNAME/cinnamon-config/cinnamon-catppcn.conf


rm -rf /tmp/.cinnamon
rm -rf /tmp/.local
rm -rf /tmp/cinnamon-config


