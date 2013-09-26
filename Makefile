#!/usr/bin/make -f
# Makefile for LINBO
# (C) Klaus Knopper <knoppix@knopper.net> 2013
# License: GPL V2

CMDLINE  = loglevel=4 nmi_watchdog=0 debug apm=power-off

VESAMODE = 0 # Don't activate VESA FB
# VESAMODE = 791 # 1024x768, 64k colors

# Configuration, these are evaluated by scripts and need export.

# Define which kernel to download and compile for LINBO
export KVERS    = 3.9.10

export PACKAGES = dkms mate-core kmod vim iproute busybox locales firmware-linux vim-tiny dbus dbus-x11 udev dosfstools e2fsprogs cifs-utils nfs-common xorg xserver-xorg-core xserver-xorg xserver-xorg-video-intel xserver-xorg-video-radeon xserver-xorg-video-nouveau xserver-xorg-video-openchrome xserver-xorg-input-evdev xserver-xorg-video-all xserver-xorg-input-kbd xserver-xorg-input-mouse libgl1-mesa-dri libgl1-mesa-glx libgl1-mesa-dri-experimental libdrm-intel1 libdrm-nouveau1a libdrm-radeon1 libdrm2 iceweasel iceweasel-l10n-de libnspr4 hdparm console-tools console-data inetutils-syslogd sudo kexec-tools xterm x11-xserver-utils xinit metacity ttf-dejavu xfonts-base less openssh-client coreutils rsync openssh-server libmotif4  python python-gtk2 zenity dialog 

# Define kernel architecture. Currently, we support intel/amd 32 and 64bit
# 	If CROSS is true, we'll build for the other architecture than the buildsystem runs on 
# export CROSS = false

# Define the CPU architecture for testing LINBO in kvm
# export CPU = kvm64
export CPU = qemu64
export MEM = 2040

# My packages
#EXTRA_PACKAGES = Sources/libntfs-3g31_2009.4.4AC.14_i386.deb Sources/ntfs-3g-ng_2009.4.4AC.14_i386.deb Sources/rsync_3.0.6-1_i386.deb Sources/cloop-utils_2.0-1_i386.deb Sources/hwsetup_1.4-21_all.deb Sources/usleep-knoppix_0.5-2_i386.deb

EXTRA_PACKAGES = Sources/hwsetup_1.4-19_all.deb Sources/usleep-knoppix_0.5-1_i386.deb

# My scripts
EXTRA_SCRIPTS = Sources/Linbo/linbo_cmd

# Dirs for upload
UPLOAD_DIRS = Bin Filesystem Image Initrd Kernel Scripts Sources

help:
	@echo "[1mWELCOME TO THE LINBO BUILD SYSTEM"
	@echo ""
	@echo "make kernel		(Re-)Build Kernel packages"
	@echo "make kernel-install	(Re-)Install Kernel packages"
	@echo "make initrd		(Re-)Build Initramfs"
	@echo "make chroot		Work inside Filesystem"
	@echo "make filesystem  	Bootstrap and fill the LINBO ./Filesystem directory"
	@echo "make update      	Install or update required packages in LINBO ./Filesystem"
	@echo "make compressed   	Compress base filesystem image."
	@echo "make iso		Make bootable iso (CD or DVD)"
	@echo "make distclean   	Remove all resources that can be recreated."
	@echo "make test		Run ISO in kvm"
	@echo
	@echo "Don't worry about the sequence of build commands, this Makefile will tell you"
	@echo "what to do first, in case anything is missing."
	@echo
	@echo "Have a lot of fun. ;-)"
	@echo "[0m"

# Meta-Targets

all-new:
	-rm -f Image.iso
#	-rm -f clean-stamp
	make knoppix cd de initrd compressed iso
	mv -f Image.iso Image-DVD-EN.iso

distclean:
	sudo rm -rf Filesystem/* Image/boot/isolinux/linux* Image/boot/isolinux/minirt.gz Kernel/* *-stamp

chroot: Filesystem ./Scripts/LINBO.chroot
	rm -f clean-stamp
	sudo Scripts/LINBO.chroot ./Filesystem

# Build-Targets

filesystem: 
	make filesystem-stamp

filesystem-stamp: ./Scripts/LINBO.mkfilesystem
	-rm -f update-stamp clean-stamp
	./Scripts/LINBO.mkfilesystem
	touch $@

knoppify: filesystem-stamp
	make knoppify-stamp

knoppify-stamp: ./Scripts/LINBO.chroot
	-rm -f clean-stamp
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "ln -snf /bin/bash /bin/sh; apt-get update; apt-get install locales busybox"
	Scripts/LINBO.knoppify Sources/Knoppix Filesystem
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/LINBO.knoppify-chroot
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/LINBO.mkfilesystem64-chroot
	touch knoppify-stamp

otcify: filesystem-stamp
	make otcify-stamp

otcify-stamp: ./Scripts/LINBO.chroot
	-rm -f clean-stamp
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "ln -snf /bin/bash /bin/sh; apt-get update; apt-get install locales busybox"
	Scripts/LINBO.apply-configs Sources/tcos Filesystem
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/LINBO.otcify-chroot
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/LINBO.mkfilesystem64-chroot
	touch $@ 

update: filesystem-stamp otcify-stamp
	make update-stamp

update-stamp: 	
	-rm -f clean-stamp
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get update; apt-get install -y --no-install-recommends $(PACKAGES)"
	touch $@



clean-stamp: filesystem-stamp ./Scripts/LINBO.otcify-clean
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/LINBO.otcify-clean
	touch $@

compressed: Filesystem clean-stamp Scripts/LINBO.mkcompressed Bin/create_compressed_fs
	-mkdir -p Image/KNOPPIX
	nice -10 ionice -c 3 sudo ./Scripts/LINBO.mkcompressed Filesystem Image/KNOPPIX/KNOPPIX

compressed-squashfs: filesystem-stamp otcify-stamp update-stamp clean-stamp
	-mkdir -p Image-new
	nice -10 ionice -c 3 sudo mksquashfs Filesystem Image-new/base.sfs -noappend -always-use-fragments
	sudo scp Image-new/base.sfs root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root/sfs/base.sfs

addons: Addons
	cd $< ; sudo mkisofs -l -R -U -v . | ../Bin/create_compressed_fs -L -2 -B 131072 -m - ../Image/KNOPPIX/KNOPPIX1

extra-packages:
	make extra-packages-stamp

extra-packages-stamp: filesystem-stamp Scripts/LINBO.chroot
	-rm -f clean-stamp
	@for i in $(EXTRA_PACKAGES); do [ -r "$$i" ] || { echo "Please build package $$i first." >&2; exit 1; } ; done
	ln -nf $(EXTRA_PACKAGES) Filesystem/tmp/
	sudo ./Scripts/LINBO.chroot Filesystem bash -c "apt-get update; apt-get install libpopt0 pciutils"
	sudo ./Scripts/LINBO.chroot Filesystem bash -c "cd /tmp; dpkg -i $(notdir $(EXTRA_PACKAGES))"
	touch extra-packages-stamp

extra-scripts:
	make extra-scripts-stamp

extra-scripts-stamp:
	-rm -f clean-stamp
	@for i in $(EXTRA_SCRIPTS); do [ -r "$$i" ] || { echo "Please provide script $$i first." >&2; exit 1; } ; done
	sudo install -m 755 $(EXTRA_SCRIPTS) Filesystem/usr/bin/
	touch extra-scripts-stamp

kernel:
	make kernel-stamp

kernel-stamp: ./Scripts/LINBO.kernel
	rm -f kernel-install-stamp
	./Scripts/LINBO.kernel
	touch kernel-stamp

env:
	Scripts/LINBO.env

#kernel64: $(KERNEL)
#	@echo "[1mBuilding $(ARCH64) kernel...[0m"
#	cd $(KERNEL) && \
#	( grep -q '^CONFIG_X86_64' .config || cp .config.64 .config ) && \
#	make -j16 ARCH="$(ARCH64)" bzImage modules && \
#	 rm -rf debian; MODULE_LOC=`pwd`/../modules fakeroot make-kpkg --arch=$(ARCH64) --cross-compile=- --append-to-version=-64 --us --uc kernel_image modules_image kernel_headers kernel_source
#

#modules-only: $(KERNEL)
#	@echo "[1mBuilding additional modules...[0m"
#	cd $(KERNEL) && \
#	 CONCURRENCY_LEVEL=16 ARCH=i386 MODULE_LOC=`pwd`/../modules fakeroot make-kpkg --us --uc modules
#
#install-modules modules-install:
#	rm -f clean-stamp
#	cd $(KERNEL) && cp ../*module*.deb ../../Filesystem/tmp/
#	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -i /tmp/*module*.deb"
#	-sudo /sbin/depmod -ae -b Filesystem $(KVERS)
#

kernel-install: filesystem-stamp kernel-stamp
	make kernel-install-stamp

kernel-install-stamp: Scripts/LINBO.chroot
	-mkdir -p Image/boot/isolinux
	ln -nf Kernel/linux-image-$(KVERS)*.deb Kernel/linux-headers-$(KVERS)*.deb Filesystem/tmp/
	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -l libncursesw5 | grep -q '^i' || { apt-get update; apt-get install libncursesw5; } ; apt-get --purge remove linux-headers-\* linux-image-\*; dpkg -i /tmp/linux-*$(KVERS)*.deb; /etc/kernel/header_postinst.d/dkms $(KVERS) /boot/vmlinuz-$(KVERS)"
	[ -r Filesystem/boot/vmlinuz-$(KVERS) ] && cp -uv  Filesystem/boot/vmlinuz-$(KVERS) Image/boot/isolinux/linux || true
	[ -r Filesystem/boot/vmlinuz-$(KVERS)-64 ] && cp -uv Filesystem/boot/vmlinuz-$(KVERS)-64 Image/boot/isolinux/linux64 || true
	touch kernel-install-stamp

initrd: Initrd
	-mkdir -p Image/boot/isolinux
	( cd Initrd && find . | sudo cpio -H newc -ov | gzip -9v ) > Image/boot/isolinux/minirt.gz

iso: Image Scripts/LINBO.mkfinal
	-rm -f Image/KNOPPIX/KNOPPIX.tmp
	Scripts/LINBO.mkfinal Image Image.iso

boot-iso: Image
	@echo "[1mCreating kernel-only boot iso image...[0m"
	mkisofs -input-charset ISO-8859-1 -pad -l -r -J \
          -V "KNOPPIX_BOOT" -A "KNOPPIX_BOOT" \
          -no-emul-boot -boot-load-size 4 -boot-info-table \
	  -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
          -hide-rr-moved \
          -m KNOPPIX -m \*.html -o Image-bootonly.iso Image || bailout 1
	@echo "[1mKernel-only boot iso image created.[0m"

de: Bootfiles/$@
	sed -i -e 's/lang=../lang=$@/g;s/# *KBDMAP german.kbd/KBDMAP german.kbd/g' Image/boot/isolinux/isolinux.cfg
	cp -f Bootfiles/$@/* Image/boot/isolinux/

en: Bootfiles/$@
	sed -i -e 's/lang=../lang=$@/g;s/^KBDMAP german.kbd/# KBDMAP german.kbd/g' Image/boot/isolinux/isolinux.cfg
	cp -f Bootfiles/$@/* Image/boot/isolinux

knoppix: Image/boot/isolinux/isolinux.cfg
	sed -i -e 's/DEFAULT .*$$/DEFAULT knoppix/g' Image/boot/isolinux/isolinux.cfg

adriane: Image/boot/isolinux/isolinux.cfg
	sed -i -e 's/DEFAULT .*$$/DEFAULT adriane/g' Image/boot/isolinux/isolinux.cfg

Data/mkisofs.sort:
	Scripts/LINBO.mksortlist Filesystem

sda.img:
	qemu-img create -f qcow2 -o cluster_size=4k,preallocation=metadata $@ 5G

kvm:
	[ -d /sys/module/kvm_intel -o -d /sys/module/kvm_amd ] || for i in intel amd; do sudo modprobe kvm_$$i; done || true

server: kvm Image.iso
	@echo "[1mStarting Knoppix as SERVER in kvm...[0m"
	kvm -cpu $(CPU) -name knoppix-server -vga std -monitor stdio $(VNCOPTS) -usb -m 800 -soundhw es1370 -boot d -cdrom Image.iso -net nic,macaddr=66:44:45:30:30:19 -net user,net=10.0.2.0/24,host=10.0.2.2,hostfwd=tcp:127.0.0.1:2022-10.0.2.2:22,hostfwd=tcp:127.0.0.1:8000-10.0.2.15:80,hostfwd=tcp:127.0.0.1:8443-10.0.2.2:443 -net socket,listen=127.0.0.1:21212

client: kvm Image.iso
	@echo "[1mStarting Knoppix as CLIENT in kvm...[0m"
	kvm -cpu $(CPU) -name knoppix-client -vga std -monitor stdio $(VNCOPTS) -usb -m 256 -soundhw es1370 -boot n -net nic,model=rtl8139,macaddr=08:00:27:A7:F1:B7 -net socket,connect=127.0.0.1:21212

test: kvm Image.iso sda.img
	@echo "[1mStarting LINBO in kvm...[0m"
	kvm -cpu $(CPU) $(VNCOPTS) -usb -m $(MEM) -vga vmware -monitor stdio -soundhw es1370 -boot d -cdrom Image.iso -hda sda.img

hdtest: kvm sda.img
	@echo "[1mStarting Knoppix in kvm...[0m"
	kvm -cpu $(CPU) $(VNCOPTS) -usb -m $(MEM) -monitor stdio -soundhw es1370 -boot c -hda sda.img -fda fd0.img

efitest: sda.img
	kvm -cpu $(CPU) $(VNCOPTS) -usb -m $(MEM) -monitor stdio -soundhw es1370 -L Ovmf/ -hda sda.img -fda fd0.img
#	qemu-system-x86_64 $(VNCOPTS) -usb -m 800 -monitor stdio -soundhw es1370 -L /usr/share/qemu/ -bios /usr/share/ovmf/OVMF.fd -hda sda.img -fda fd0.img

vnctest: kvm Image.iso
	$(MAKE) VNCOPTS="-vnc :10 -k de" test

flash:
	cd Image && flash-knoppix

burn: Image.iso
	sudo cdrecord -v -dao -eject speed=8 Image.iso
