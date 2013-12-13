#!/bin/bash
sudo dpkg -i /tmp/linux-image-3.2.52+tcos_1_i386.deb
sudo mkdir /lib/modules/3.2.52+tcos/kernel/drivers/gpu/drm/via_chrome9
sudo cp /tmp/kernel-module/3.2/via_chrome9.ko /lib/modules/3.2.52+tcos/kernel/drivers/gpu/drm/via_chrome9/
sudo depmod -a
sudo modprobe via_chrome9
sudo cp /tmp/xorg/via_drv.so /usr/lib/xorg/modules/drivers/
sudo cp /tmp/xorg/libGL.so.1.2 /usr/lib/i386-linux-gnu/
sudo mkdir /etc/X11/xorg.conf.d/
sudo cp /tmp/xorg/10-via.conf /etc/X11/xorg.conf.d/
cd /usr/lib/i386-linux-gnu
sudo ln -snf libGL.so.1.2 libGL.so.1

