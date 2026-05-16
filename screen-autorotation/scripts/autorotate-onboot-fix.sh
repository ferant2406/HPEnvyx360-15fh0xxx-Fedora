#!/bin/bash
echo "Starting: autorotate-onboot-fix.sh - Fix automatic screen rotation on boot..."

CURRENT_STATE=$(gsettings get org.gnome.settings-daemon.peripherals.touchscreen orientation-lock)

echo "  Current rotation lock state is ($CURRENT_STATE) (true=enabled, false=disabled)"

if [ "$CURRENT_STATE" = "false" ]; then
  echo "  Rotation lock already disabled, nothing else to do."
  echo "  Reloading amd_sfh module..."
  sudo modprobe -r amd_sfh -v
  sleep 0.1
  sudo modprobe amd_sfh -v
  echo "  amd_sfh module reloaded!"
  echo "  Waiting for 15 seconds..."
  sleep 15
  echo "  Restarting iio-sensor-proxy service..."
  sudo systemctl restart iio-sensor-proxy -v
  echo "  iio-sensor-proxy service restarted!"
else
  echo "  Disabling screen rotation lock..."
  gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock false
  echo "  New rotation lock state is ($(gsettings get org.gnome.settings-daemon.peripherals.touchscreen orientation-lock)) (true=enabled, false=disabled)"
  echo "  Reloading amd_sfh module..."
  sudo modprobe -r amd_sfh -v
  sleep 0.1
  sudo modprobe amd_sfh -v
  echo "  amd_sfh module reloaded!"
  echo "  Waiting for 15 seconds..."
  sleep 15
  echo "  Restarting iio-sensor-proxy service..."
  sudo systemctl restart iio-sensor-proxy -v
  echo "  iio-sensor-proxy service restarted!"
fi

echo "All operations were completed!"
