#!/bin/bash

#Disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#Disable IP6 in GRUB or SYSTEM_CONFIG
grubby --update-kernel=ALL --args="ipv6.disable=1"
#sysctl -w net.ipv6.conf.all.disable_ipv6=1
#sysctl -w net.ipv6.conf.default.disable_ipv6=1
#sysctl -w net.ipv6.conf.lo.disable_ipv6=1
sysctl -p
nmcli connection modify ens192 ipv6.method "disabled"
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client

#Setup system
dnf upgrade -y

dnf install -y pcp pcp-system-tools pcp-gui
systemctl enable --now pmcd pmlogger
systemctl enable cockpit.socket

dnf install -y krb5-workstation
dnf install -y mc

#Reboot
reboot
