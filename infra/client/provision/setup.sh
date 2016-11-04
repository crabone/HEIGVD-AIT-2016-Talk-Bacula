#!/bin/bash

echo "Installing Bacula (Client)"
yum update
yum install -y bacula-common bacula-client
echo "Done !"

echo "Create directory for restoring files, and set correct permissions"
mkdir -p /bacula/restore
chown -R bacula:bacula /bacula
chmod -R 700 /bacula

# Comment if SELinux is disabled or not installed.
restorecon -R /bacula
echo "Done !"

echo "Generate certificates for files encryption"
openssl genrsa -out master.key 2048
openssl req -new -key master.key -x509 -out master.cert -subj "/C=CH/ST=Vaud/L=Yverdon/O=AIT/CN=foo.bar"

openssl genrsa -out fd-client.key 2048
openssl req -new -key fd-client.key -x509 -out fd-client.cert -subj "/C=CH/ST=Vaud/L=Yverdon/O=AIT/CN=foo.bar"

cat fd-client.key fd-client.cert > fd-client.pem

mv fd-client.pem /etc/bacula/
mv master.cert /etc/bacula/

chown root:root /etc/bacula/fd-client.pem /etc/bacula/master.cert
chmod 640 /etc/bacula/fd-client.pem /etc/bacula/master.cert
# Comment if SELinux is disabled or not installed.
restorecon -R /bacula

rm master.key fd-director.key fd-director.cert
echo "Done !"

echo "Set configuration for the Bacula Client"
cp /vagrant/bacula-fd.conf /etc/bacula/bacula-fd.conf
chown root:root /etc/bacula/bacula-fd.conf
chmod 640 /etc/bacula/bacula-fd.conf

# Comment if SELinux is disabled or not installed.
restorecon -R /etc/bacula
echo "Done !"

echo "Update /etc/hosts"
echo "192.168.33.2  director" >> /etc/hosts
echo "192.168.33.3  storage" >> /etc/hosts
echo "192.168.33.4  admin" >> /etc/hosts
echo "Done !"

echo "Start daemons and enable on boot"
systemctl stop bacula-fd
systemctl start bacula-fd
systemctl enable bacula-fd
echo "Done !"

echo "Deploy home environment"
mkdir /home/vagrant/Music
cp -r /vagrant/Music/HRZNEP015_-_Yazid_Le_Voyageur_-_Soul_Mates /home/vagrant/Music/
echo "Done !"
