#!/bin/bash

echo "Installing Bacula (Storage)"
dnf install -y bacula-common bacula-storage
echo "Done !"

echo "Create directory for backup files, and set correct permissions"
mkdir -p /bacula/backup
chown -R bacula:bacula /bacula
chmod -R 700 /bacula

# Comment if SELinux is disabled or not installed.
restorecon -R /bacula
echo "Done !"

echo "Set configuration for the Bacula Storage Daemon"
cp /vagrant/bacula-sd.conf /etc/bacula/bacula-sd.conf
chown root:root /etc/bacula/bacula-sd.conf
chmod 640 /etc/bacula/bacula-sd.conf

# Comment if SELinux is disabled or not installed.
restorecon -R /bacula
echo "Done !"

echo "Update /etc/hosts"
echo "192.168.33.2  director" >> /etc/hosts
echo "192.168.33.4  admin" >> /etc/hosts
echo "192.168.33.5  client" >> /etc/hosts
echo "Done !"

echo "Start daemons and enable on boot"
systemctl stop bacula-sd
systemctl start bacula-sd
systemctl enable bacula-sd
echo "Done !"
