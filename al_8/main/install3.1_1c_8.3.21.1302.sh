#!/bin/bash

#Add 1c GROUP and USER
echo 'Create 1c user and group...' 
groupadd -r grp1cv8 --gid=9998
useradd -r -m -g grp1cv8 --uid=9998 usr1cv8

#Change access rights
echo 'Create folder and set permision...'
if [ ! -d "/_data/srv1c_inf_log" ] ; then
	mkdir /_data/srv1c_inf_log
fi
chown -R usr1cv8:grp1cv8 /_data/srv1c_inf_log
chmod -R 700 /_data/srv1c_inf_log

#Install 1C Enterprise requirements from STANDART repositories
echo 'Dowload and install addons...'
dnf install -y postgresql-odbc
dnf install -y libgsf

#Install 1C Enterprise requirements from EPEL repositories
dnf install -y epel-release
dnf install -y ImageMagick

#Install 1C Enterprise server requirements from custom packages
curl "https://drive.usercontent.google.com/download?id=1-6UeVusRsqn33AAmAozG_NH-CmHDwKMx&confirm=xxx" -o msttcorefonts-2.5-1.noarch.rpm
rpm -ivh msttcorefonts-2.5-1.noarch.rpm
fc-cache /usr/share/fonts

#Install 1C Enterprise server packages from work dir
#Download form GOOGLE
curl "https://drive.usercontent.google.com/download?id=1eYMu7e0KNAfByJMZqjNsUPjf3slyQBxJ&confirm=xxx" -o setup-full-8.3.21.1302-x86_64.run
chmod +x setup-full-8.3.21.1302-x86_64.run
#ATTENTION! Batch installation will always install the 1c client and, if missing, the trimmed GNOME
./setup-full-8.3.21.1302-x86_64.run --mode unattended --disable-components client_full,client_thin,client_thin_fib,config_storage_server,liberica_jre,integrity_monitoring --enable-components server,server_admin,ws,additional_admin_functions,uk,ru
#Manual installation, if have GUI (GNOME), the process will run in it
#./setup-full-8.3.21.1302-x86_64.run

sed -ri 's/Environment=SRV1CV8_DEBUG=/Environment=SRV1CV8_DEBUG=-debug/' /opt/1cv8/x86_64/8.3.21.1302/srv1cv8-8.3.21.1302@.service
sed -ri 's/Environment=SRV1CV8_DATA=\/home\/usr1cv8\/.1cv8\/1C\/1cv8/Environment=SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /opt/1cv8/x86_64/8.3.21.1302/srv1cv8-8.3.21.1302@.service

systemctl link /opt/1cv8/x86_64/8.3.21.1302/srv1cv8-8.3.21.1302@.service
systemctl link /opt/1cv8/x86_64/8.3.21.1302/ras-8.3.21.1302.service
systemctl enable srv1cv8-8.3.21.1302@default
systemctl enable ras-8.3.21.1302
systemctl start srv1cv8-8.3.21.1302@default
systemctl start ras-8.3.21.1302

curl "https://drive.usercontent.google.com/download?id=1RND475Sc9MquDt9W1At9rMQP_N6OOfSk&confirm=xxx" -o /etc/firewalld/services/srv1c.xml
firewall-cmd --permanent --add-service=srv1c
firewall-cmd --reload

#Make change for httpd(Apache)
printf "\nInclude /_data/httpd/conf/extra/httpd-1C-pub.conf\n" >> /etc/httpd/conf/httpd.conf
systemctl restart httpd
