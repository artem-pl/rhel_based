#!/bin/bash

#Register on RedHat
echo 'System must be registered on RedHat site...'
subscription-manager register
insights-client --register

#Disable IP6 in GRUB or SYSTEM_CONFIG
echo 'Disabel IPv6...'
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) ipv6.disable=1"
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client

#Disable selinux
echo 'Disable selinux...'
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#Setup system
dnf upgrade -y

dnf install -y pcp pcp-system-tools pcp-gui
systemctl enable --now pmcd pmlogger
systemctl enable cockpit.socket

dnf install -y krb5-workstation
dnf install -y mc

#Reboot
reboot
