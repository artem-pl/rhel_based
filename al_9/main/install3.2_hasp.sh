#!/bin/bash

#Make driver USB-HASP
curl "https://drive.usercontent.google.com/download?id=1jYDXDzhh6d-239v7sKGg_Y9jLXdB_nl5&confirm=xxx" -o usbhasp.tar.gz
tar -x usbhasp.tar.gz
cd usbhasp
bash ./install.sh

#Copy KEY file and restart service
curl "https://drive.usercontent.google.com/download?id=1ig3A3-p2j7JyeWnbANMMHNbeqE_us_hI&confirm=xxx" -o C6565506-x64.json
curl "https://drive.usercontent.google.com/download?id=10sg3tKayquve5iQu2KHZEidLhOf1SiYW&confirm=xxx" -o EDCDF9E0-net300.json
systemctl restart usbhaspd
lsusb