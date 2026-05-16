#!/bin/bash
echo "Starting: autorotate-aftersuspend-fix.sh - Fix flipped screen on wake from suspend..."

CURRENT_SCREENLOCK_STATE=$(gsettings get org.gnome.settings-daemon.peripherals.touchscreen orientation-lock)

echo "	Current rotation lock state is ($CURRENT_SCREENLOCK_STATE) (true=enabled, false=disabled)"
echo "	Restarting iio-sensor-proxy service..."
sudo systemctl restart iio-sensor-proxy -v
echo "	iio-sensor-proxy service restarted!"
echo "	Disabling screen rotation lock..."
gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock false
echo "	New rotation lock state is ($(gsettings get org.gnome.settings-daemon.peripherals.touchscreen orientation-lock)) (true=enabled, false=disabled)"
echo "All operations were completed!"
