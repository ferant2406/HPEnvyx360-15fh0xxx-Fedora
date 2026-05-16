#!/bin/bash
echo "Starting: autorotate-beforesuspend-fix.sh - Lock screen rotation to fix flipped screen on wake from suspend..."

CURRENT_STATE=$(gsettings get org.gnome.settings-daemon.peripherals.touchscreen orientation-lock)

echo "  Current rotation lock state is ($CURRENT_STATE) (true=enabled, false=disabled)"

if [ "$CURRENT_STATE" = "true" ]; then
  echo "  Rotation lock already disabled, nothing else to do."
else
  echo "  Enabling screen rotation lock..."
  gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true
  echo "  New rotation lock state is ($(gsettings get org.gnome.settings-daemon.peripherals.touchscreen orientation-lock)) (true=enabled, false=disabled)"
fi

echo "All operations were completed!"
