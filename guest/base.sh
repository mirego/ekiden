#!/bin/bash

# Enable passwordless sudo
echo runner | sudo -S sh -c "echo 'runner ALL=(ALL) NOPASSWD: ALL' | EDITOR=tee visudo /etc/sudoers.d/admin-nopasswd"

# Enable auto-login
# See https://github.com/xfreebird/kcpassword for details.
# echo '00000000: 0ffc 3c4d b7ce ddea a3b9 1f0a' | sudo xxd -r - /etc/kcpassword
echo '00000000: 0ffc 3c4d b7ce ddea a3b9 1f0a' | sudo xxd -r - /etc/kcpassword
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser runner

# Disable screensaver at login screen
sudo defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0

# Prevent the VM from sleeping
sudo systemsetup -setdisplaysleep Off
sudo systemsetup -setsleep Off
sudo systemsetup -setcomputersleep Off

# Launch Safari to populate the defaults
/Applications/Safari.app/Contents/MacOS/Safari &
sleep 30
kill -9 %1

# Disable screen lock
sysadminctl -screenLock off -password runner

# Disable Spotlight
sudo mdutil -a -i off
