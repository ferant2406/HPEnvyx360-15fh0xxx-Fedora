Fixes and configuration for the HP Envy x360 15-fh0xxx on Fedora 44 Workstation
===============================================================================

Fixes I've come across using Fedora Linux on the HP Envy x360 15-fh0xxx and personal
configuration. These fixes were tested in Fedora 44 Workstation with Gnome DE. Some of these
might work on other Distros and DEs.

Notes
=====
These fixes and configurations were tested in Fedora 44 running kernel 7.1.5-201. Depending
on when you are reading this, some of these fixes might not be necessary anymore, and I'll try
to keep this guide updated. Bios version used to make this guide is F.15.

I recommend disabling Secure Boot, as it makes some of the fixes easier to implement. They
should also work with Secure Boot enabled if you make the necessary tweaks.

List of Programs I Use
----------------------
- Discord ([Flathub](https://flathub.org/en/apps/com.discordapp.Discord))
- Dropbox ([via the Dropbox official website](https://www.dropbox.com/install-linux))
- Extension Manager ([Flathub](https://flathub.org/en/apps/com.mattjakeman.ExtensionManager))
- Steam (RPM fusion non-free)
- GIMP (Fedora Linux)
- LocalSend ([Flathub](https://flathub.org/en/apps/org.localsend.localsend_app))
- Mission Center ([Flathub](https://flathub.org/en/apps/io.missioncenter.MissionCenter))
- Flatseal (Fedora Linux)
- Gear Lever ([Flathub](https://flathub.org/en/apps/it.mijorus.gearlever))
- Main Menu ([Flathub](https://flathub.org/en/apps/page.codeberg.libre_menu_editor.LibreMenuEditor))
- MiKTeX ([via the MiKTeX official website](https://miktex.org/download))
- Neovim (Fedora Linux)
- Rclone Browser ([via their github repository](https://github.com/kapitainsky/RcloneBrowser#how-to-get-it))(See fixes section)
- Rewaita ([Flathub](https://flathub.org/en/apps/io.github.swordpuffin.rewaita))
- Tweaks (Fedora Linux)
- Veracrypt ([via the Veracrypt official website](https://veracrypt.jp/en/Downloads.html))
- VLC (Fedora Linux)
- Xournal++ (Fedora Linux)
- Zathura ([Flathub](https://flathub.org/en/apps/org.pwmt.zathura))
- Zoom Workplace ([via the Zoom official website](https://zoom.us/download?os=linux))

List of Gnome Extensions I Use
------------------------------
- [Alphabetical App Grid](https://extensions.gnome.org/extension/4269/alphabetical-app-grid/)
- [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)
- [Auto Power Profile](https://extensions.gnome.org/extension/6583/auto-power-profile/)
- [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
- [Custom Command Toggle](https://extensions.gnome.org/extension/7012/custom-command-toggle/)
- [Removable Drive Menu](https://extensions.gnome.org/extension/7/removable-drive-menu/)
- [Screen Rotate](https://extensions.gnome.org/extension/5389/screen-rotate/) (This extension is mandatory if you want to enable automatic screen rotation, see fixes section)
- [Status Area Horizontal Spacing](https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/)
- [Touchpad Switcher](https://extensions.gnome.org/extension/7373/touchpad-switcher/)
- [UXPlay Control](https://extensions.gnome.org/extension/8243/uxplay-control/)

Table of Contents
-----------------
Fixes
- [Add touchscreen-stylus to libwacom (FIXED)](#add-touchscreen-stylus-to-libwacom)
- [Fan profile using NBFC](#fan-profile-using-nbfc)
- [Mute LEDs (FIXED)](#mute-leds)
- [Rclone Browser with ptyxis](#rclone-browser-with-ptyxis)
- [Screen Autorotation](#screen-autorotation)
- [UxPlay Fix](#uxplay-fix)

Configuration
- [Add template to nautilus context menu](#add-template-to-nautilus-context-menu)
- [Better Fonts](#better-fonts)
- [Disable CPU turbo boost](#disable-cpu-turbo-boost)
- [Screen saver](#screen-saver)
- [Traffic Light Buttons](#traffic-light-buttons)

Add touchscreen-stylus to libwacom
----------------------------------
ALREADY IMPLEMENTED IN THE MAIN LIBWACOM LIBRARY AS OF (5/28/2026) AND IS NO LONGER NECCESARY
---------------------------------------------------------------------------------------------
The HP Envy x360 15-fh0xxx uses the ELAN2513 touchscreen-stylus, but it is not recognized by
the system. Depending on when you are reading this, [this pull request](https://github.com/linuxwacom/libwacom/pull/973)
might already be implemented on the main [libwacom](https://github.com/linuxwacom/libwacom)
library, but until then you can manually add the stylus to the library.

- Copy the `elan-2513.tablet` file into `/etc/libwacom/`:
```
$ cd add-touchscreen-stylus-libwacom
$ sudo cp elan-2513.tablet /etc/libwacom/
```
`elan-2513.tablet`
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
- Run `libwacom-update-db` to regenerate the udev hardware database so the device gets
properly tagged:
```
$ libwacom-update-db /etc/libwacom
```
- Restart your system and run `$ libwacom-list-local-devices`. The stylus should be
recognized correctly in Gnome Settings -> Graphics Tablets.

Fan profile using NBFC
----------------------
[ACPI Platform Prifle](https://docs.kernel.org/userspace-api/sysfs-platform_profile.html)
does not work correctly on this laptop. This seems to be a reported issue [1](https://www.reddit.com/r/linuxquestions/comments/1p6d65o/power_profiles_do_not_work_on_hp_laptop/)
[2](https://bugzilla.kernel.org/show_bug.cgi?id=220008) [3](https://h30434.www3.hp.com/t5/Gaming-Notebooks/Fan-control-completely-non-functional-on-Linux-due-to-broken/td-p/9632498)
[4](https://github.com/pelrun/hp-omen-linux-module/issues/38) [5](https://forums.linuxmint.com/viewtopic.php?t=456899)
with HP Laptops. This results in the fans not working correctly. To solve this issue, we can
use custom fan curves with the help of Notebook Fan Control.

- First you need to install the `acpi_ec` and `acpi_call` modules. To install `acpi_ec` you
can use these [instructions](https://github.com/saidsay-so/acpi_ec). To install `acpi_call`
you can use these [instructions](). The next set of instructions explain how to manually
install `acpi_ec` and `acpi_call` with secure boot enabled. If you are not using secure boot
skip the MOK enrollment key step.

Setup DKMS and enroll the MOK key:
```
$ sudo dnf install dkms openssl
$ sudo dkms generate_mok
$ sudo mokutil -i /var/lib/dkms/mok.pub
```
When prompted for a password, use a simple one (like "fedora"). After rebooting, press any
key to enter MOK management at the blue screen. Select “Enroll MOK”, choose “Continue”, 
select “Yes”, enter password “fedora” at the password prompt, then reboot.

Clone the `acpi_ec` repository:
```
$ git clone https://github.com/saidsay-so/acpi_ec.git
$ cd acpi_ec
```
Make these changes to the `dkms.conf` file:
```
$ sudo nano dkms.conf
```
`dkms.conf`
```
PACKAGE_NAME="acpi_ec"
PACKAGE_VERSION="1.0.4"
BUILT_MODULE_NAME[0]="acpi_ec"
BUILT_MODULE_LOCATION[0]="src"
DEST_MODULE_LOCATION[0]="/extra"
MAKE[0]="make -C $kernel_source_dir M=$dkms_tree/acpi_ec/1.0.4/build/src modules"
CLEAN="make -C $kernel_source_dir M=$dkms_tree/acpi_ec/1.0.4/build/src clean"
AUTOINSTALL=yes
```
Create the source directories and copy the files:
```
$ sudo mkdir -p /usr/src/acpi_ec-1.0.4
$ sudo cp -r * /usr/src/acpi_ec-1.0.4
```
Build the module:
```
$ sudo dkms build -m acpi_ec -v 1.0.4
$ sudo dkms install -m acpi_ec -v 1.0.4
```
Manually load the module:
```
$ sudo modprobe acpi_ec -v
```
Check if the module is loaded properly:
```
$ lsmod | grep acpi_ec
```
Finally, to always load the module open `$ sudo nano /etc/modules-load.d/acpi_ec.conf` and
just write `acpi_ec`.

To install `acpi_call` the process is pretty much the same. Clone the `acpi_call` repository:
```
$ git clone https://github.com/nix-community/acpi_call.git
$ cd acpi_call
```
Copy the included `dkms.conf` file:
```
$ cp dkms.conf.in dkms.conf
```
Create the source directories and copy the files (check the version number):
```
$ sudo mkdir -p /usr/src/acpi_call-1.2.2
$ sudo cp -r * /usr/src/acpi_call-1.2.2
```
Build the module:
```
$ sudo dkms build -m acpi_call -v 1.2.2
$ sudo dkms install -m acpi_call -v 1.2.2
```
Manually load the module:
```
$ sudo modprobe acpi_call -v
```
Check if the module is loaded properly:
```
$ lsmod | grep acpi_call
```
Finally, to always load the module open `$ sudo nano /etc/modules-load.d/acpi_call.conf` and
just write `acpi_call`.
- Install Notebook Fan Control using the instructions on their [repository](https://github.com/nbfc-linux/nbfc-linux)
- Copy the profile configuration files to the nbfc configuration files
```
$ cd fan-profile-using-nbfc/configs
$ sudo cp -r * /usr/share/nbfc/configs/
```
- Enable any configuration you want (Included are a default fan curve and a silent one). You 
can use these configuration files as templates to make your own fan curves.
```
$ sudo nbfc config --set "HP ENVY x360 2-in-1 Laptop 15-fh0xxx (Default)"
```
- Edit the `nbfc` configuration to use `acpi_ec` method and restart:
```
$ sudo nano /etc/nbfc/nbfc.json
```
`nbfc.json`
```
{
 "SelectedConfigId": "HP Envy x360 2-in-1 Laptop 15-fh0xxx (Default)",
 "EmbeddedControllerType": "acpi_ec",
 "FanTemperatureSources": [
  {
   "FanIndex": 0,
   "TemperatureAlgorithmType": "Max",
   "Sensors": [
    "@CPU"
   ]
  }
 ]
}
```
```
$ sudo nbfc restart
```
- Enable the service to start automatically on boot:
```
$ sudo systemctl enable nbfc_service
```
You can monitor the fan and temperature using `$ watch -n 1 nbfc status`.

- Optionally, you can create a shortcut to switch between silent and default fan curve using
the [Custom Command Toggle](https://extensions.gnome.org/extension/7012/custom-command-toggle/)
extension:

Make the commands require no password using a `sudoers` file:
```
$ sudo visudo -f /etc/sudoers.d/nbfc
```
`nbfc`
```
ALL ALL=(ALL) NOPASSWD: /usr/bin/nbfc config --set *
ALL ALL=(ALL) NOPASSWD: /usr/bin/nbfc restart
```
Create a new toggle with this configuration:
```
[Toggle 1]
button-name=Silent Fan
icon=weather-windy-symbolic
toggle-on-command=sudo nbfc config --set "HP ENVY x360 2-in-1 Laptop 15-fh0xxx (Silent)" && sudo nbfc restart
toggle-off-command=sudo nbfc config --set "HP ENVY x360 2-in-1 Laptop 15-fh0xxx (Default)" && sudo nbfc restart
check-status-command=nbfc status
search-term=Silent
initial-state=3
run-at-startup=false
startup-delay-time=3
check-status-delay-time=3
button-click-action=2
check-exit-code=false
show-indicator=true
close-menu=false
command-sync=false
polling-frequency=10
keyboard-shortcut=
enabled=true
```
You can now change profiles from the Gnome System Menu.

MUTE LEDs
---------
IMPLEMENTED ON KERNEL VERSION 7.0.12-201
----------------------------------------
Depending on when you are reading this, this [patch](https://lore.kernel.org/all/20260504-hpenvy-muteled-fix-v3-1-5567fd9b3d25@gmail.com/) 
might already be implemented in the linux kernel. But until then, you'll need to compile the 
kernel with the appropiate patch. This patch has been tested on kernel version 7.0.8-200. 
Follow this [guide](https://docs.fedoraproject.org/en-US/quick-docs/kernel-build-custom/#_building_a_kernel_from_the_fedora_dist_git) 
to compile your own kernel.
```
linux-kernel-test.patch
```

```
diff -rupN kernel_src_folder/sound/hda/codecs/realtek/alc269.c kernel_src_folder_patched/sound/hda/codecs/realtek/alc269.c
--- kernel_src_folder/sound/hda/codecs/realtek/alc269.c	2026-05-15 06:53:54.000000000 -0600
+++ kernel_src_folder_patched/sound/hda/codecs/realtek/alc269.c	2026-05-16 12:32:33.604572427 -0600
@@ -4138,6 +4138,7 @@ enum {
 	ALC245_FIXUP_ACER_MICMUTE_LED,
 	ALC245_FIXUP_CS35L41_I2C_2_MUTE_LED,
 	ALC236_FIXUP_HP_DMIC,
+	ALC245_FIXUP_HP_ENVY_X360_15_FH0XXX,
 };

 /* A special fixup for Lenovo C940 and Yoga Duet 7;
@@ -6684,6 +6685,12 @@ static const struct hda_fixup alc269_fix
 			{ 0x12, 0x90a60160 }, /* use as internal mic */
 			{ }
 		},
+	},
+	[ALC245_FIXUP_HP_ENVY_X360_15_FH0XXX] = {
+		.type = HDA_FIXUP_FUNC,
+		.v.func = cs35l41_fixup_i2c_two,
+		.chained = true,
+		.chain_id = ALC245_FIXUP_HP_X360_MUTE_LEDS
 	}
 };

@@ -7102,7 +7109,7 @@ static const struct hda_quirk alc269_fix
 	SND_PCI_QUIRK(0x103c, 0x8be6, "HP Envy 16", ALC287_FIXUP_CS35L41_I2C_2),
 	SND_PCI_QUIRK(0x103c, 0x8be7, "HP Envy 17", ALC287_FIXUP_CS35L41_I2C_2),
 	SND_PCI_QUIRK(0x103c, 0x8be8, "HP Envy 17", ALC287_FIXUP_CS35L41_I2C_2),
-	SND_PCI_QUIRK(0x103c, 0x8be9, "HP Envy 15", ALC287_FIXUP_CS35L41_I2C_2),
+	SND_PCI_QUIRK(0x103c, 0x8be9, "HP Envy x360 2-in-1 Laptop 15-fh0xxx", ALC245_FIXUP_HP_ENVY_X360_15_FH0XXX),
 	SND_PCI_QUIRK(0x103c, 0x8bf0, "HP", ALC236_FIXUP_HP_GPIO_LED),
 	SND_PCI_QUIRK(0x103c, 0x8c15, "HP Spectre x360 2-in-1 Laptop 14-eu0xxx", ALC245_FIXUP_HP_SPECTRE_X360_EU0XXX),
 	SND_PCI_QUIRK(0x103c, 0x8c16, "HP Spectre x360 2-in-1 Laptop 16-aa0xxx", ALC245_FIXUP_HP_SPECTRE_X360_16_AA0XXX),
```

Rclone Browser with ptyxis
--------------------------
While the core features on Rclone Browser work, it doesn't recognize the terminal `ptyxis` as
it was later implemented in Fedora to replace the `gnome-terminal`, leading to an error
trying to open the `rclone` configuration from inside  Rclone Browser. The fix is to build
Rclone Browser with the patched `main_windows.cpp` file. Just follow the instructions in the
[Rclone Browser repository](https://github.com/kapitainsky/RcloneBrowser) using the patched
file. This fixed was made for Rclone Browser version `1.8.0`.

Screen Autorotation
-------------------
The `amd_sfh` module fails to load the accelerometer on boot (I've only seen it load
correctly two times back when I was dual booting Linux Mint and Windows). This is a
[reported bug](https://bugzilla.kernel.org/show_bug.cgi?id=212615) and there's no fix as of
today. We can workaround this bug and restore automatic rotation.

First, you need to download and enable the [Screen Rotate](https://extensions.gnome.org/extension/5389/screen-rotate/) 
extension. Then we can reload the `amd_sfh` module using `modprobe` and restart
`iio-sensor-proxy` service:
```
$ sudo modprobe -r amd_sfh -v
$ sudo modprobe amd_sfh -v
$ sudo systemctl restart iio-sensor-proxy
```
If this works and your rotation is working, the rest of this "fix" will work on your system
(you can test this by rotating your screen or looking at the output of `monitor-sensor` in
terminal. Some notes about this:
- When applying this fix, after suspending and waking the laptop, the screen will be flipped
and the `iio-sensor-proxy` sensor is stuck on "bottom-up" orientation. A restart of
`iio-sensor-proxy` fixes this issue.
- If the automatic rotation lock is enabled, a restart of `iio-sensor-proxy` might not be
enough to restore automatic rotation on boot, and you'll have to disable screen rotation and
restart `iio-sensor-proxy`.

So the fix I've come up with is using `systemd` services on boot, before and after suspend to
reload the `amd_sfh` module, enable and disable the screen rotation lock as necessary and
restart `iio-sensor-proxy` service:
- Copy the script files to `/usr/local/bin/`. Make the scripts executable using `sudo chmod +x`:
```
$ cd screen-autorotation/scripts
$ chmod +x *
$ sudo cp -r * /usr/local/bin/
```
- Make the necessary commands require no password using a `sudoers` file:
```
$ sudo visudo -f /etc/sudoers.d/autorotatefix
```
`autorotatefix`
```
ALL ALL=(ALL) NOPASSWD: /bin/systemctl restart iio-sensor-proxy -v
ALL ALL=(ALL) NOPASSWD: /usr/bin/modprobe -r amd_sfh -v
ALL ALL=(ALL) NOPASSWD: /usr/bin/modprobe amd_sfh -v
```
- Create a `systemd` service to run on boot. This service will reload the `amd_sfh` module,
disable the screen rotation lock and restart the `iio-sensor-proxy` service. I've found that
delaying the restart of `iio-sensor-proxy` by 15 seconds yielded the best results (check the
scripts for details).
```
$ sudo nano /etc/systemd/system/autorotate-onboot-fix.service
```
`autorotate-onboot-fix.service`
```
[Unit]
Description=Fix automatic screen rotation on boot
After=multi-user.target iio-sensor-proxy.service

[Service]
Type=oneshot
# Your username here
# Example: User=john
User=MYUSERNAME
# The output of the command: echo $DBUS_SESSION_BUS_ADDRESS
# It should look like: $ echo $DBUS_SESSION_BUS_ADDRESS -> unix:path=/run/user/1000/bus
# Example: Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
Environment="DBUS_SESSION_BUS_ADDRESS=YOURDBUSSESSIONADDRESS"
RemainAfterExit=no
ExecStart=/bin/bash -c "/usr/local/bin/autorotate-onboot-fix.sh"

[Install]
WantedBy=multi-user.target
```
- Create a `systemd` service to run before suspend. This service will enable the screen
rotation lock before suspend so the screen is not flipped when waking up from suspend.
```
$ sudo nano /etc/systemd/system/autorotate-beforesuspend-fix.service
```
`autorotate-beforesuspend-fix.service`
```
[Unit]
Description=Lock screen rotation to fix flipped screen on wake from suspend
Before=systemd-suspend.service

[Service]
Type=oneshot
# Your username here
# Example: User=john
User=MYUSERNAME
# The output of the command: echo $DBUS_SESSION_BUS_ADDRESS
# It should look like: $ echo $DBUS_SESSION_BUS_ADDRESS -> unix:path=/run/user/1000/bus
# Example: Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
Environment="DBUS_SESSION_BUS_ADDRESS=YOURDBUSSESSIONADRESS"
RemainAfterExit=no
ExecStart=/bin/bash -c "/usr/local/bin/autorotate-beforesuspend-fix.sh"

[Install]
WantedBy=systemd-suspend.service
```
- Create a `systemd` service to run after suspend. This service will restart the
`iio-sensor.proxy` service to fix orientation being stuck on "bottom-up" and disable the
screen rotation lock.
```
$ sudo nano /etc/systemd/system/autorotate-aftersuspend-fix.service
```
`autorotate-aftersuspend-fix.service`
```
[Unit]
Description=Fix flipped screen on wake from suspend
After=systemd-suspend.service

[Service]
Type=oneshot
# Your username here
# Example: User=john
User=MYUSERNAME
# The output of the command: echo $DBUS_SESSION_BUS_ADDRESS
# It should look like: $ echo $DBUS_SESSION_BUS_ADDRESS -> unix:path=/run/user/1000/bus
# Example: Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
Environment="DBUS_SESSION_BUS_ADDRESS=YOURDBUSSESSIONADRESS"
RemainAfterExit=no
ExecStart=/bin/bash -c "/usr/local/bin/autorotate-aftersuspend-fix.sh"

[Install]
WantedBy=systemd-suspend.service
```
- Enable the services:
```
$ sudo systemctl daemon-reload
$ sudo systemctl enable autorotate-onboot-fix.service
$ sudo systemctl enable autorotate-beforesuspend-fix.service
$ sudo systemctl enable autorotate-aftersuspend-fix.service
```
- Now you can test if automatic rotation is enabled on boot and after waking from suspend.
The automatic rotation might take a couple of seconds to be enabled on boot. You can check
the services output using `journalctl` and `systemd status`.

UxPlay Fix
----------
[UxPlay](https://github.com/fdh2/uxplay) is an AirPlay Unix mirroring server, allowing you
to mirror your Apple device's screen to your PC. I've had issues with the quality of the
mirror image and the instructions on this [reddit post](https://www.reddit.com/r/Fedora/comments/1r7j8ad/comment/o93fgd9/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)
helped me:
- You must add [Fedora Fusion RPM](https://rpmfusion.org/Configuration) source. Follow the
official instructions.

- Check if `avdech264` exists.
```
$ gst-inspect-1.0 avdec_h264
```
- Install codec `h264` and `h265` (allow erasing).
```
$ sudo dnf update
$ sudo dnf install ffmpeg-libs gstreamer1-libav --allowerasing
```
- Remove cache to refresh.
```
$ rm -rf ~/.cache/gstreamer-1.0
$ gst-inspect-1.0 avdec_h264
```
- Force UxPlay to run with official codec `H264` instead of `openH264`.
```
$ uxplay -avdec
```
- Now can use UxPlay normally (normally, if `avdech264` exists, the system will use the official
instead of the open codec. You can run UxPlay without `-avdec` now.

- You can monitor the UxPlay process via `GStreams`
```
GST_DEBUG=3 uxplay -avdec
```
- You can also monitor via UxPlay using `uxplay -d`. For more details run `uxplay -help`

Add template to nautilus context menu
-------------------------------------
Sometimes I want to make a quick text file using the right click context menu. Simply add
an empty text file to the `Templates` folder.
```
touch ~/Templates/"New Text File.txt"
```

Better Fonts
------------
I find the style of MacOS fonts pretty, and I wanted to make the Fedora font style as close
to the MacOS font style as I can.
- Set fonts in Gnome-Tweaks to `Adawaita Sans` or `Noto Sans` (my personal favorite is `Noto Sans`)
- Set mono space to `Noto Sans Mono`
- Add this environment variable
```
$ sudo nano /etc/environment
```
```
  FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"
```
The fonts should look a little more like they do in MacOS.

Disable CPU turbo boost
-----------------------
The HP Envy x360 15-fh0xxx is equipped with the Ryzen 5 7530U and while it doesn't get very
hot, most of the time I work on light tasks and would rather have less heat and power
consumption. We can create a `systemd` service to disable the CPU turbo boost:
- Create a `systemd` service named `cpu-noturbo.service`:
```
$ sudo nano /etc/systemd/system/cpu-noturbo.service
```
`cpu-noturbo.service`
```
[Unit]
Description=Disable Turbo Boost

[Service]
RemainAfterExit=yes
ExecStart=/bin/bash -c "echo 0 | tee /sys/devices/system/cpu/cpufreq/boost"
ExecStop=/bin/bash -c "echo 1 | tee /sys/devices/system/cpu/cpufreq/boost"

[Install]
WantedBy=sysinit.target
```
- Enable the service:
```
$ systemctl --user daemon-reload
$ systemctl --user enable cpu-noturbo
```
This way, Turbo Boost will be disabled every time you start the system. To enable Turbo Boost
just stop the service. I used this [guide](https://medo64.com/posts/disabling-amd-turbo-boost)
as reference.
- Optionally, we can use the [Custom Command Toggle](https://extensions.gnome.org/extension/7012/custom-command-toggle/)
extension to quickly enable and disable Turbo Boost as we need:

Make the necessary commands require no password with a `sudoers` file:
```
$ sudo visudo -f /etc/sudoers.d/cpunoturbo
```
`cpunoturbo`
```
ALL ALL=(ALL) NOPASSWD: /bin/systemctl start cpu-noturbo
ALL ALL=(ALL) NOPASSWD: /bin/systemctl stop cpu-noturbo
```
Create a toggle with this configuration:
```
[Toggle 2]
button-name=CPU Turbo
icon=uninterruptible-power-supply-symbolic
toggle-on-command=sudo systemctl stop cpu-noturbo
toggle-off-command=sudo systemctl start cpu-noturbo
check-status-command=cat /sys/devices/system/cpu/cpufreq/boost
search-term=1
initial-state=3
run-at-startup=false
startup-delay-time=3
check-status-delay-time=3
button-click-action=2
check-exit-code=false
show-indicator=true
close-menu=false
command-sync=false
polling-frequency=10
keyboard-shortcut=
enabled=true
```
You can now enable and disable Turbo Boost from the Gnome System Menu.

Screen saver
------------
The HP Envy x360 15-fh0xxx comes with an OLED display. OLED Displays are susceptible to OLED
burn in, and while gnome turns off the screen after some time, this also deactivates output
to any external monitor connected to the laptop. `Wayland` doesn't really support screen
savers, but we can simulate one with a looping video as we just want something to refresh
the image on the screen. I used this [guide](https://circuitshelter.com/posts/run-custom-screensaver-on-modern-gnome-desktops/)
as a reference for the scripts.

- Install `mpv`:
```
$ sudo dnf install mpv
```
- Copy the scripts to `~/.local/bin/`. Make sure you edit the scripts to use your videos as
a screen saver:
```
$ cd screen-saver/scripts
$ chmod +x *
$ mkdir -p ~/.local/bin/
$ cp -r * ~/.local/bin/
```
- Create a user `systemd` service to handle the script:
```
$ mkdir -p ~/.config/systemd/user/
$ nano ~/.config/systemd/user/screensaver.service
```
`screensaver.service`
```
[Unit]
Description=Enable screensaver to appear when iddle
After=graphical-session.target

[Service]
Type=simple
# Your home directory here
# Example: ExecStart=/home/john/.local/bin/afterdark.sh
ExecStart=MYHOMEDIRECTORY/.local/bin/afterdark.sh
Restart=no
KillMode=process

[Install]
WantedBy=default.target
```
- We can use [Custom Command Toggle](https://extensions.gnome.org/extension/7012/custom-command-toggle/)
to make a quick toggle of the screen saver:
```
[Toggle 3]
button-name=Screensaver
icon=preferences-desktop-screensaver-symbolic
toggle-on-command=systemctl --user start screensaver.service
toggle-off-command=systemctl --user stop screensaver.service
check-status-command=systemctl --user status screensaver.service
search-term=active (running)
initial-state=3
run-at-startup=false
startup-delay-time=3
check-status-delay-time=3
button-click-action=2
check-exit-code=false
show-indicator=true
close-menu=false
command-sync=false
polling-frequency=10
keyboard-shortcut=
enabled=true
```
- Additionally, we can create a keyboard shortcut to activate a short timeout screen saver
in System -> Keyboard -> Custom Shortcuts:
```
Name     : Screensaver
Command  : ptyxis --title 'Screensaver' -- bash -c 'trap "exit 0" INT; MYHOMEDIRECTORY/.local/bin/afterdark_short.sh; exec bash'
Shortcut : #Whatever you want your shortcut to be, I use CTRL+ALT+S
```

Traffic Light Buttons
---------------------
I like the style of traffic light buttons style from MacOS. The easiest way of getting the
same style on gnome is to install [Rewaita](https://flathub.org/en/apps/io.github.swordpuffin.rewaita).
If you don't want to install Rewaita, you can just copy the necessary `gtk` files:
- Copy the `gtk.css` files to their respective directory:
```
$ cd traffic-light-buttons
$ cp -r * ~/.config/
```
- Finally, add this options under All Applications -> Fylesystem -> Other Files, in Flatseal:
```
  All Applications:
    Fylesystem:
      Other Files:
        |- xdg-config/gtk-3.0
        |- xdg-config/gtk-4.0
```
