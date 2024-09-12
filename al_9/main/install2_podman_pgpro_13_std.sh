#!/bin/bash
clear

#Install PODMAN
dnf install -y podman 

#Add POSTGRES GROUP and USER same as in container
echo 'Create postgres user and group...' 
groupadd -r postgres --gid=9999
useradd -r -M -g postgres --uid=9999 postgres

#Change access rights
echo 'Create folder and set permision...'
if [ ! -d "/_data/pg_backup" ] ; then
	mkdir /_data/pg_backup
fi
if [ ! -d "/_data/pg_data" ] ; then
	mkdir /_data/pg_data
fi
chown -R postgres:postgres /_data/pg_backup
chmod -R 777 /_data/pg_backup
chown -R postgres:postgres /_data/pg_data
chmod -R 700 /_data/pg_data

#Start POSTGRESPRO container
#Change the image name to the desired image. Example kostikpl/ol9:pgpro_1c_13 > kostikpl/rhel8:pgpro_std_13
echo 'Pull and setup container...'
HOSTNAME=`hostname`
podman run --shm-size 2G --name pgpro --hostname $HOSTNAME -dt -p 5432:5432 -v /_data:/_data docker.io/kostikpl/al_9:pgpro_std_13
podman generate systemd --new --name pgpro > /etc/systemd/system/pgpro.service
systemctl enable --now pgpro
firewall-cmd --permanent --add-service=postgresql
firewall-cmd --reload
sleep 15s
PG_PASSWD='RheujvDhfub72'
podman exec -ti pgpro psql -c "ALTER USER postgres WITH PASSWORD '$PG_PASSWD';"
#srv1c_PASSWD = '\$GitybwZ - ZxvtyM\$' # $GitybwZ - ZxvtyM$
#podman exec -ti pgpro psql -c "ALTER USER srv1c WITH PASSWORD '$srv1c_PASSWD';"
podman run --name pgadmin -d -p 5050:80 -e 'PGADMIN_LISTEN_ADDRESS=0.0.0.0' -e 'PGADMIN_DEFAULT_EMAIL=k.druchevsky@kernel.ua' -e 'PGADMIN_DEFAULT_PASSWORD=a1502EMC2805' docker.io/dpage/pgadmin4
podman generate systemd --new --name pgpro > /etc/systemd/system/pgadmin.service
systemctl enable --now pgadmin
firewall-cmd --permanent --add-port=5050/tcp
firewall-cmd --reload