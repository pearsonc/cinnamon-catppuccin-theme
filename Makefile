VERSION := 1.0.28-1
PACKAGE_NAME := cinnamon-catppuccin-theme
DEBIAN_PACKAGE_DIR := bin/$(PACKAGE_NAME)_$(VERSION)_amd64
DEBIAN_CONTROL_FILE_SRC := package_metadata/control

THEME_DIR = $(DEBIAN_PACKAGE_DIR)/usr/share/themes
ICONS_DIR = $(DEBIAN_PACKAGE_DIR)/usr/share/icons
FONTS_DIR = $(DEBIAN_PACKAGE_DIR)/usr/share/fonts
WALLPAPERS_DIR = $(DEBIAN_PACKAGE_DIR)/usr/share/backgrounds/
WALLPAPER_PROPERTIES_DIR = $(DEBIAN_PACKAGE_DIR)/usr/share/cinnamon-background-properties/
TMP_DIR = $(DEBIAN_PACKAGE_DIR)/tmp


# Main targets
.PHONY: build clean

build: setup_build_environment copy_control_file copy_theme_files copy_icon_files copy_font_files copy_wallpaper_files copy_cinnamon_dconf build_deb

setup_build_environment:
	@mkdir -p $(DEBIAN_PACKAGE_DIR)/DEBIAN
	@cp -r postinst.sh $(DEBIAN_PACKAGE_DIR)/DEBIAN/postinst
	@chmod 775 $(DEBIAN_PACKAGE_DIR)/DEBIAN/postinst

copy_control_file:
	@cp $(DEBIAN_CONTROL_FILE_SRC) $(DEBIAN_PACKAGE_DIR)/DEBIAN/control

copy_theme_files:
	@mkdir -p $(THEME_DIR)
	@cp -r  "theme-files/themes/Catppuccin-Mocha-Standard-Pink-Dark" $(THEME_DIR)

copy_icon_files:
	@mkdir -p $(ICONS_DIR)
	@cp -r  "theme-files/icons/Catppuccin-Mocha-MOD" $(ICONS_DIR)
	@cp -r  "theme-files/start-menu-icon" $(ICONS_DIR)
	@cp -r  "theme-files/cursors/Catppuccin-Mocha-Dark-Cursors" $(ICONS_DIR)

copy_font_files:
	@mkdir -p $(FONTS_DIR)
	@cp -r  "theme-files/fonts/" $(FONTS_DIR)

copy_wallpaper_files:
	@mkdir -p $(WALLPAPERS_DIR)
	@mkdir -p $(WALLPAPER_PROPERTIES_DIR)
	@cp -r  "theme-files/linuxmint-catppuccin" $(WALLPAPERS_DIR)
	@cp "linuxmint-catppuccin.xml" $(WALLPAPER_PROPERTIES_DIR)

copy_cinnamon_dconf:
	@cp -r "theme-files/cinnamon-applet-config" $(TMP_DIR)
	@cp -r "theme-files/cinnamon-config" $(TMP_DIR)


build_deb:
	@dpkg --build $(DEBIAN_PACKAGE_DIR)
	@echo "Package built at $(DEBIAN_PACKAGE_DIR).deb"

clean:
	@rm -rf ./bin