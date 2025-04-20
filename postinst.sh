#!/bin/bash

echo "Post install and configuration script running now"

# dconf dump /org/cinnamon/ > ~/dconf-cinnamon.bck.dconf

# Setting default applications
#File manager to Nautilus
xdg-mime default org.gnome.Nautilus.desktop inode/directory application/x-gnome-saved-search
# Video files to VLC
xdg-mime default vlc.desktop video/mp4
xdg-mime default vlc.desktop video/x-matroska
xdg-mime default vlc.desktop video/x-msvideo
xdg-mime default vlc.desktop video/x-flv
xdg-mime default vlc.desktop video/webm
xdg-mime default vlc.desktop video/quicktime
xdg-mime default vlc.desktop video/x-ms-wmv
#Audio files to Rhythmbox
xdg-mime default org.gnome.Rhythmbox3.desktop audio/mpeg
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-wav
xdg-mime default org.gnome.Rhythmbox3.desktop audio/flac
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-vorbis+ogg
xdg-mime default org.gnome.Rhythmbox3.desktop audio/mp4
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-ms-wma


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

# Proceed with user-specific operations, copying files
mkdir -p /home/$USERNAME/.config/autostart
cp -r /tmp/.cinnamon/configs/* /home/$USERNAME/.config/cinnamon/spices
cp -r /tmp/.local/ /home/$USERNAME/
cp -r /tmp/plank-theme-config/.local/ /home/$USERNAME/
cp -r /tmp/plank-theme-config/.config/ /home/$USERNAME/
cp -r /tmp/conky-config/conky /home/$USERNAME/.config/
cp -r /tmp/conky-config/autostart/conky-grumicela.desktop /home/$USERNAME/.config/autostart/conky-grumicela.desktop
#cp -r /tmp/glava-config/.config/glava /home/$USERNAME/.config/
#cp -r /tmp/glava-config/.config/autostart/glava-radial.desktop /home/$USERNAME/.config/autostart/glava-radial.desktop
cp -r /tmp/cinnamon-config/ /home/$USERNAME/

cat > /home/$USERNAME/.config/autostart/plank.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Comment=Simple dock application
Exec=plank
OnlyShowIn=GNOME;Unity;XFCE;LXDE;MATE;Cinnamon;
X-GNOME-Autostart-enabled=true
Hidden=false
EOF

# Set permissions and ownerships
chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/cinnamon/spices
chown -R $USERNAME:$USERNAME /home/$USERNAME/.local
chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
chown -R $USERNAME:$USERNAME /home/$USERNAME/cinnamon-config

chmod -R u+rwX,go-rwx /home/$USERNAME/.config/cinnamon/spices
chmod -R 700 /home/$USERNAME/.local
chmod -R u+rwX,go-rwx /home/$USERNAME/cinnamon-config
chmod -R 775 /home/$USERNAME/.config/plank
chmod -R 775 /home/$USERNAME/.config/autostart

# Load dconf settings as the user
sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
    dconf load /org/cinnamon/ < /home/$USERNAME/cinnamon-config/cinnamon-catppcn.conf

sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
    dconf write /org/gnome/desktop/interface/monospace-font-name "'FiraCode Nerd Font Mono weight=450 10'"

sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
    dconf write /org/nemo/desktop/font "'Roboto 10'"

sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
    dconf write /net/launchpad/plank/docks/dock1/theme "'cattpcn-dark'"


if ! grep -q "^MUFFIN_NO_SHADOWS=" /etc/environment; then
    echo "MUFFIN_NO_SHADOWS=1" | sudo tee -a /etc/environment > /dev/null
    echo "MUFFIN_NO_SHADOWS=1 has been added to /etc/environment"
else
    echo "MUFFIN_NO_SHADOWS is already set in /etc/environment"
fi


### Build and configure Glava

#ldconfig
#GLAVA_DIR="/home/$USERNAME/glava"
#BUILD_DIR="$GLAVA_DIR/build"
#
## Check if the glava directory exists
#if [ ! -d "$GLAVA_DIR" ]; then
#    echo "Cloning the glava repository..."
#    # Clone the repository as the specified user
#    sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
#        git clone https://github.com/jarcode-foss/glava.git $GLAVA_DIR
#else
#    echo "Directory $GLAVA_DIR already exists. Skipping git clone."
#fi
#
## Proceed to compile and install Glava
#echo "Compiling and installing Glava..."
#
## Change to the glava directory (as root, but for safety we should also ensure the user has proper access)
#cd $GLAVA_DIR
#
## Set up the build directory if it doesn't exist
#if [ ! -d "$BUILD_DIR" ]; then
#    mkdir -p $BUILD_DIR
#fi
#
## Run meson to configure the build, as the specified user
#sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
#    meson $BUILD_DIR --prefix=/usr
#
## Build with ninja, as the specified user
#sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
#    ninja -C $BUILD_DIR
#
## Install with sudo (as root), since the installation requires root privileges
#echo "Installing Glava..."
#sudo ninja -C $BUILD_DIR install
#
#echo "Glava has been successfully installed."








# Clean up temp files
rm -rf /tmp/.cinnamon
rm -rf /tmp/.local
rm -rf /tmp/cinnamon-config
rm -rf /home/$USERNAME/cinnamon-config


# Restart Cinnamon
cinnamon --replace &