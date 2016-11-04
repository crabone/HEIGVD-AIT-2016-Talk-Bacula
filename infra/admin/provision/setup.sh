#!/bin/bash

echo "Installing Bacula (Client/Admin)"
dnf install -y bacula-common bacula-client bacula-console
echo "Done !"

echo "Installing OpenSSL" 
dnf install -y openssl
echo "Done !"

echo "Create directory for restoring files, and set correct permissions"
mkdir -p /bacula/restore
chown -R bacula:bacula /bacula
chmod -R 700 /bacula

# Comment if SELinux is disabled or not installed.
restorecon -R /bacula
#restorecon -R -i /bacula
echo "Done !"

echo "Generate certificates for files encryption"
openssl genrsa -out master.key 2048
openssl req -new -key master.key -x509 -out master.cert -subj "/C=CH/ST=Vaud/L=Yverdon/O=AIT/CN=foo.bar"

openssl genrsa -out fd-admin.key 2048
openssl req -new -key fd-admin.key -x509 -out fd-admin.cert -subj "/C=CH/ST=Vaud/L=Yverdon/O=AIT/CN=foo.bar"

cat fd-admin.key fd-admin.cert > fd-admin.pem

mv fd-admin.pem /etc/bacula/
mv master.cert /etc/bacula/

chown root:root /etc/bacula/fd-admin.pem /etc/bacula/master.cert
chmod 640 /etc/bacula/fd-admin.pem /etc/bacula/master.cert
# Comment if SELinux is disabled or not installed.
restorecon -R /bacula

rm master.key fd-admin.key fd-admin.cert
echo "Done !"

echo "Set configuration for the Bacula Client"
cp /vagrant/bacula-fd.conf /etc/bacula/bacula-fd.conf
chown root:root /etc/bacula/bacula-fd.conf
chmod 640 /etc/bacula/bacula-fd.conf

cp /vagrant/bconsole.conf /etc/bacula/bconsole.conf
chown root:root /etc/bacula/bconsole.conf
chmod 640 /etc/bacula/bconsole.conf

# Comment if SELinux is disabled or not installed.
restorecon -R /etc/bacula
echo "Done !"

echo "Update /etc/hosts"
echo "192.168.33.2  director" >> /etc/hosts
echo "192.168.33.3  storage" >> /etc/hosts
echo "192.168.33.5  client" >> /etc/hosts
echo "Done !"

echo "Start daemons and enable on boot"
systemctl stop bacula-fd
systemctl start bacula-fd
systemctl enable bacula-fd
echo "Done !"

echo "Deploy home environment"
cp -r /vagrant/Pictures /home/vagrant/
echo "Done !"
