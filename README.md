Fixes and configuration for the HP Envy x360 15 fh0xxx on Fedora 44 Workstation
===============================================================================

Fixes I've come across using Fedora on the HP Envy x360 15-fh0xxx and personal configuration.
This fixes were tested in Fedora 44 Workstation with Gnome DE. Some of these might work on 
other Distros and DEs.

Notes
=====
These fixes and configurations were tested in Fedora 44 running kernel 6.19.14-300 and Gnome
version 50. Depending on when you are reading this, some of these fixes might not be
necesary anymore and I'll try to keep this guide updated.

Bios version used to make this guide is F.14. If you have an older bios I recommend sticking
with whatever version you have unless you are experiencing a serious problem with your 
system, as you won't be able to te revert back to an older version and newer versions can
end up breaking more things than fixing.

List of Programs I Use
----------------------
- Discord ([Flathub](https://flathub.org/en/apps/com.discordapp.Discord))
- Dropbox ([via the Dropbox official website](https://www.dropbox.com/install-linux))
- Extension Manager ([Flathub](https://flathub.org/en/apps/com.mattjakeman.ExtensionManager))
- Steam (RPM fusion non-free)
- GIMP (Fedora Linux)
- LocalSend ([Flathub](https://flathub.org/en/apps/org.localsend.localsend_app))
- RcloneBrowser (See ToC)
- Mission Center ([Flathub](https://flathub.org/en/apps/io.missioncenter.MissionCenter))
- Flatseal (Fedora Linux)
- Gear Lever ([Flathub](https://flathub.org/en/apps/it.mijorus.gearlever))
- Main Menu ([Flathub](https://flathub.org/en/apps/page.codeberg.libre_menu_editor.LibreMenuEditor))
- Neovim (Fedora Linux)
- Tweaks (Fedora Linux)
- VLC (Fedora Linux)
- Zoom Workplace ([via the Zoom official website](https://zoom.us/download?os=linux))

List of Gnome Extensions I Use
------------------------------
- [Alphabetical App Grid](https://extensions.gnome.org/extension/4269/alphabetical-app-grid/)
- [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)
- [Auto Power Profile](https://extensions.gnome.org/extension/6583/auto-power-profile/)
- [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
- [Custom Command Toggle](https://extensions.gnome.org/extension/7012/custom-command-toggle/)
- [Removable Drive Menu](https://extensions.gnome.org/extension/7/removable-drive-menu/)
- [Screen Rotate](https://extensions.gnome.org/extension/5389/screen-rotate/)
- [Status Area Horizontal Spacing](https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/)
- [Touchpad Switcher](https://extensions.gnome.org/extension/7373/touchpad-switcher/)


Table of Contents
-----------------
Fixes
- [Add touchscreen-stylus to libwacom](#add-touchscreen-stylus-to-libwacom)
- [Fan profile using NBFC](#fan-profile-using-nbfc)
- [Mute LEDs](#mute-leds)
- [Rclone Browser with ptyxis](#rclone-browser-with-ptyxis)
- [Screen Autorotation](#screen-autorotation)
  
Configuration
- [Add template to nautilus context menu](#add-template-to-nautilus-context-menu)
- [Better Fonts](#better-fonts)
- [Better Power Profiles](#better-power-profiles)
- [Disable CPU turbo boost](#disable-cpu-turbo-boost)
- [Screen saver](#screen-saver)
- [Traffic Light Buttons](#traffic-light-buttons)


Add touchscreen-stylus to libwacom
----------------------
The HP Envy x360 15-fh0xxx uses the ELAN2513 touchscreen-stylus, but it is not recognized by the system.
Depending on when you are reading this, [this pull request](https://github.com/linuxwacom/libwacom/pull/973) might already
be implemented on the main [libwacom]() library, but until then you can manually add the 
stylus to the library.

- Copy the `elan-2513.tablet` file:
```
# ELAN touchscreen/pen sensor present in the HP Envy x360 15-fhxxx

[Device]
Name=ELAN 2513
ModelName=
DeviceMatch=i2c|04f3|4162
Class=ISDV4
IntegratedIn=Display;System

[Features]
Stylus=true
Touch=true
```
  into `/etc/libwacom/`
```
sudo cp elan-2513.tablet /etc/libwacom/
```
- Run `libwacom-update-db` to regenerate the udev hardware database so the device gets properly tagged:
```
libwacom-update-db /etc/libwacom
```
- Restart your system and run `libwacom-list-local-devices`, the stylus should be recognized correctly
in Gnome Settings -> Graphics Tablets

Fan profile using NBFC
----------------------
By default, the fan curve on my laptop is unresponsive, making it so the fan never speeds up even when
reaching the 80°C. To solve this issue, we can use custom fan curves with the help of Notebook Fan Control.

MUTE LEDs
---------
Depending on when you are reading this, this fix might already be implemented in the linux kernel. But until then,
you'll need to compile the kernel with the appropiate patch

Rclone Browser with ptyxis
--------------------------
While the core features on Rclone Browser work, it doesn't recognize the terminal `ptyxis` as it was later 
implemented in Gnome to replace the `gnome-terminal`, leading to an error trying to open the `rclone` configuration
from inside Rclone Browser.

Automatic Screen Rotation
-------------------------
The `amd_sfh` module fails to load the accelerometer data at boot. This bug is well documented and as of
today there is not a fix. We can restore the automatic screen rotation using a workaround.

