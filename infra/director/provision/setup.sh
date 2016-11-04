#!/bin/bash

echo "Installing Bacula (Director/Catalog)"
dnf install -y bacula-common bacula-director bacula-storage bacula-console bacula-client
echo "Done !"

echo "Installing OpenSSL" 
dnf install -y openssl
echo "Done !"

echo "Set SQLite3 as default for Bacula"
alternatives --set libbaccats.so /usr/lib64/libbaccats-sqlite3.so
sed -i -e 's/default_db_type=postgresql/default_db_type=sqlite3/g' /usr/libexec/bacula/*
echo "Done !"

echo "Grant SQLite3 privileges for Bacula"
/usr/libexec/bacula/grant_sqlite3_privileges
echo "Done !"

echo "Create SQLite3 database for Bacula"
/usr/libexec/bacula/create_sqlite3_database
echo "Done !"

echo "Create tables for the newly created SQLite3 database"
/usr/libexec/bacula/make_sqlite3_tables
echo "Done !"

echo "Create directory for backup/restore files, and set correct permissions"
mkdir -p /bacula/restore
chown -R bacula:bacula /bacula
chmod -R 700 /bacula

# Comment if SELinux is disabled or not installed.
restorecon -R /bacula
echo "Done !"

echo "Generate certificates for files encryption"
openssl genrsa -out master.key 2048
openssl req -new -key master.key -x509 -out master.cert -subj "/C=CH/ST=Vaud/L=Yverdon/O=AIT/CN=foo.bar"

openssl genrsa -out fd-director.key 2048
openssl req -new -key fd-director.key -x509 -out fd-director.cert -subj "/C=CH/ST=Vaud/L=Yverdon/O=AIT/CN=foo.bar"

cat fd-director.key fd-director.cert > fd-director.pem

mv fd-director.pem /etc/bacula/
mv master.cert /etc/bacula/

chown root:root /etc/bacula/fd-director.pem /etc/bacula/master.cert
chmod 640 /etc/bacula/fd-director.pem /etc/bacula/master.cert
# Comment if SELinux is disabled or not installed.
restorecon -R /bacula

rm master.key fd-director.key fd-director.cert
echo "Done !"

echo "Set configuration for the Bacula Director"
cp /vagrant/bacula-dir.conf /etc/bacula/bacula-dir.conf
chown root:bacula /etc/bacula/bacula-dir.conf
chmod 640 /etc/bacula/bacula-dir.conf

cp -r /vagrant/conf.d /etc/bacula/
chown -R root:bacula /etc/bacula/conf.d
chmod 640 /etc/bacula/conf.d/*.conf
chmod 750 /etc/bacula/conf.d

cp /vagrant/bacula-sd.conf /etc/bacula/bacula-sd.conf
chown root:root /etc/bacula/bacula-sd.conf
chmod 640 /etc/bacula/bacula-sd.conf

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
echo "192.168.33.3  storage" >> /etc/hosts
echo "192.168.33.4  admin" >> /etc/hosts
echo "192.168.33.5  client" >> /etc/hosts
echo "Done !"

echo "Start daemons and enable on boot"
systemctl stop bacula-dir
systemctl stop bacula-sd
systemctl stop bacula-fd

systemctl start bacula-dir
systemctl start bacula-sd
systemctl start bacula-fd

systemctl enable bacula-dir
systemctl enable bacula-sd
systemctl enable bacula-fd
echo "Done !"
