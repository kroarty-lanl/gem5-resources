#!/bin/bash
# Removing snapd
snap remove $(snap list | awk '!/^Name|^core/ {print $1}') # not removing the core package as others depend on it
snap remove $(snap list | awk '!/^Name/ {print $1}')
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
apt remove --purge -y snapd
apt -y autoremove
apt -y autopurge

# Removing mounting /boot/efi
sudo sed -i '/\/boot\/efi/d' /etc/fstab
sudo systemctl stop boot-efi.mount
sudo systemctl disable boot-efi.mount

mv /home/gem5/serial-getty@.service /lib/systemd/system/
# We make the m5 binary as part of building the image
mv /home/gem5/m5 /sbin
ln -s /sbin/m5 /sbin/gem5
mv /home/gem5/gem5-init.sh /root/
chmod +x /root/gem5-init.sh
echo "/root/gem5-init.sh" >> /root/.bashrc
