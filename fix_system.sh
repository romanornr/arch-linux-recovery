#!bin/bash

echo "Backup current list of installed packages"
pacman -Qqe > /root/package_list_backup.txt

# Reinstall all packages
pacman -Qnq | pacman -S --noconfirm -

# update system
pacman -Syu --noconfirm
