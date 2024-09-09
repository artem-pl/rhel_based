#!/bin/bash

#Add 1c GROUP and USER
echo 'Create postgres user and group...' 
groupadd -r grp1cv8 --gid=9998
useradd -r -m -g grp1cv8 --uid=9998 usr1cv8

#Change access rights
echo 'Create folder and set permision...'
if [ ! -d "/_data/srv1c_inf_log" ] ; then
	mkdir /_data/srv1c_inf_log
fi
chown -R usr1cv8:grp1cv8 /_data/srv1c_inf_log
chmod -R 700 /_data/srv1c_inf_log

#Install 1C Enterprise requirements from repositories
#dnf install -y epel-release
echo 'Dowload and install addons...'
#dnf install -y imagemagick
dnf install -y unixODBC
#dnf install -y libgsf-1-114
#dnf install -y cabextract xorg-x11-font-utils fontconfig


#Install 1C Enterprise server requirements from custom packages
curl "https://drive.usercontent.google.com/download?id=1-6UeVusRsqn33AAmAozG_NH-CmHDwKMx&confirm=xxx" -o msttcorefonts-2.5-1.noarch.rpm
rpm -ivh msttcorefonts-2.5-1.noarch.rpm

#Install 1C Enterprise server packages from work dir
#Download form GOOGLE
curl "https://drive.usercontent.google.com/download?id=194Gy41zfqAZD46mad-lmPuSQ_b7NLxSP&confirm=xxx" -o server64_8_3_21_1302.tar.gz
tar -xf server64_8_3_21_1302.tar.gz
chmod +x setup-full-8.3.21.1302-x86_64.run
#ATTENTION! Batch installation will always install the 1c client and, if missing, the trimmed GNOME
./setup-full-8.3.21.1302-x86_64.run #--mode unattended --enable-components server,server_admin,ws,uk,ru
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