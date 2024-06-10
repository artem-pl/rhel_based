#!/bin/bash

cd /root
dnf -y install glibc
curl -LOJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/haspd-7.90-eter2centos.x86_64.rpm
curl -LOJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/haspd-modules-7.90-eter2centos.x86_64.rpm
dnf -y localinstall haspd*

dnf -y install gcc gcc-c++ make kernel-devel jansson-devel libusb.i686 elfutils-libelf-devel
cd /usr/src
curl -LOJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/libusb_vhci-0.8.tar.gz
curl -LOJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/vhci-hcd-1.15.tar.gz
curl -LOJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/UsbHasp-master.tar.gz
tar -xpf libusb_vhci-0.8.tar.gz
tar -xpf vhci-hcd-1.15.tar.gz
tar -xpf UsbHasp-master.tar.gz
KVER=`uname -r`

cd /usr/src/vhci-hcd-1.15
mkdir -p linux/${KVER}/drivers/usb/core
cp /usr/src/kernels/${KVER}/include/linux/usb/hcd.h linux/${KVER}/drivers/usb/core
sed -i 's/#define DEBUG/\/\/#define DEBUG/' usb-vhci-hcd.c
sed -i 's/#define DEBUG/\/\/#define DEBUG/' usb-vhci-iocifc.c
sed -i 's/VERIFY_READ, //' usb-vhci-iocifc.c
sed -i 's/VERIFY_WRITE, //' usb-vhci-iocifc.c
make KVERSION=${KVER}
make install
echo "usb_vhci_hcd" | tee /etc/modules-load.d/usb_vhci.conf
modprobe usb_vhci_hcd
echo "usb_vhci_iocifc" | tee -a /etc/modules-load.d/usb_vhci.conf
modprobe usb_vhci_iocifc

cd /usr/src/libusb_vhci-0.8
./configure
make -s
make install
echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/libusb_vhci.conf
ldconfig

cd /usr/src/UsbHasp-master
make -s
cp dist/Release/GNU-Linux/usbhasp /usr/local/sbin

mkdir /etc/usbhaspkey/
curl -LJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/1C_v8_MultiKey_100_user.json -o /etc/usbhaspkey/1C_v8_MultiKey_100_user.json
curl -LJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/1C_v8_MultiKey_Server_x64.json -o /etc/usbhaspkey/1C_v8_MultiKey_Server_x64.json

curl -LJ https://github.com/kostik-pl/rhel8-public/raw/7d5599c94292d0609503aa525dec718df1f9ec90/HASP/usbhaspemul.service -o /etc/systemd/system/usbhaspemul.service
systemctl daemon-reload

systemctl restart haspd
systemctl enable --now usbhaspemul
