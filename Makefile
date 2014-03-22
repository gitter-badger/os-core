#!/usr/bin/make -f
# Makefile for TCOS
# (C) Steffen Hoenig <s.hoenig@openthinclient.com> 2013, 2014
# (C) Jörn Frenzel <j.frenzel@openthinclient.com> 2013, 2014
# License: GPL V2

SHELL := /bin/bash

# Define which kernel to download and compile for TCOS
export KVERS      = 3.13.1
export X86        = CFLAGS="-m32" LDFLAGS="-m32" ARCH="i386"
export X86_64     = CFLAGS="-m64" LDFLAGS="-m64" ARCH="x86_64"
export BASE_PACKAGE_PATH  = root@otc-dd-dev2:/develop/base/base-2.0/debian/base
export LOCAL_TEST_PATH  = root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root
export DEB_MIRROR = http://otc-dd-01/debian
export ARCH       = i386

# Have package list in alphabetical order for better human reading. Cleanup dups.
# for package in one two three; do echo $package; done | sort -u | sed ':a;N;$!ba;s/\n/ /g'

# takes round about 30 minutes to install

export PACKAGES = xinetd pcscd pcsc-tools libccid libacsccid1 eject libglib2.0-bin gvfs flashplugin-nonfree libpopt0 pciutils usbutils xdg-utils libqt4-qt3support libqt4-sql bluez-alsa alsa-utils bluez-audio python-bluez aptitude arandr blueman cifs-utils console-data console-tools coreutils dbus dbus-x11 devilspie devilspie2  gdevilspie dosfstools dos2unix ethtool e2fsprogs file firmware-linux hdparm htop iceweasel iceweasel-l10n-de iceweasel-l10n-es-ar iceweasel-l10n-es-cl iceweasel-l10n-es-es iceweasel-l10n-es-mx iceweasel-l10n-fr iceweasel-l10n-uk iproute iputils-ping ipython kmod ldap-utils less libdrm2 libdrm-intel1 libdrm-nouveau1a libdrm-radeon1 libgl1-mesa-dri libgl1-mesa-dri-experimental libgl1-mesa-glx libmotif4 lightdm lightdm-gtk-greeter marco dconf-tools mate-themes mate-applets mozo mc devilspie devilspie2 man eom engrampa pluma atril mate-session-manager mate-media mate-desktop mate-screensaver mate-archive-keyring net-tools nfs-common ntp openssh-client openssh-server python python-gconf python-gtk2 python-ldap python-xdg rdesktop rsync screen smplayer spice-client sudo syslog-ng tcpdump ttf-dejavu udev util-linux vim vim-tiny wget x11vnc x11-xserver-utils xfonts-base xinit xorg xserver-xorg xserver-xorg-core xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-video-all xserver-xorg-video-intel xserver-xorg-video-nouveau xserver-xorg-video-openchrome xserver-xorg-video-radeon gvfs-backends mate-system-monitor libstdc++5 freerdp-X11 zenity libx11-6 libssl1.0.0 fontconfig mate-themes libgtk2.0-bin libgtk-3-bin

export EXTRAS = openthinclient-icon-theme_1-1_all.deb

help:
	@echo "[1mWELCOME TO THE TCOS BUILD SYSTEM"
	@echo ""
	@echo "make all		Metatarget: create the whole system"
	@echo "make local-test		Metatarget: + copy everthing to local test server"
	@echo "make package-prepare	Metatarget: + copy everthing to package build directory"
	@echo ""
	@echo "make kernel		(Re-)Build Kernel packages"
	@echo "make kernel-install	(Re-)Install Kernel packages"
	@echo "make initrd		(Re-)Build Initramfs"
	@echo "make chroot		Work inside Filesystem"
	@echo "make filesystem  	Bootstrap and fill the TCOS ./Filesystem directory"
	@echo "make update      	Install or update required packages in TCOS ./Filesystem"
	@echo "make compressed   	Compress base filesystem image."
	@echo "make distclean   	Remove all resources that can be recreated."
	@echo
	@echo "Don't worry about the sequence of build commands, this Makefile will tell you"
	@echo "what to do first, in case anything is missing."
	@echo
	@echo "Have a lot of fun. ;-)"
	@echo "[0m"

# Meta-Targets

distclean:
	sudo rm -rf Filesystem/* Image/boot/syslinux/linux* Image/boot/syslinux/initrd.gz Kernel/aufs-linux-* *-stamp 
	sudo find ./Initrd -xdev -samefile Initrd/bin/busybox -delete || true


chroot: Filesystem ./Scripts/LINBO.chroot
	rm -f clean-stamp
	sudo Scripts/LINBO.chroot ./Filesystem

all: compressed initrd 

# Build-Targets

filesystem: 
	make filesystem-stamp

filesystem-stamp: ./Scripts/TCOS.mkfilesystem
	@echo "[1m Target: Creating an initial filesystem[0m"
	-rm -f update-stamp clean-stamp
	./Scripts/TCOS.mkfilesystem $(DEB_MIRROR)
	touch $@

tcosify: filesystem-stamp 
	make tcosify-stamp

tcosify-stamp: ./Scripts/LINBO.chroot
	@echo "[1m Target: Applying TCOS specific changes[0m"
	-rm -f clean-stamp update-stamp
	Scripts/LINBO.apply-configs Sources/tcos Filesystem
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "ln -snf /bin/bash /bin/sh;"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "[ ! -f  /etc/issue.debian ] && cp /etc/issue /etc/issue.debian;" 
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "[ ! -f  /etc/motd.debian ] && cp /etc/motd /etc/motd.debian;"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-chroot
	touch $@ 

update: filesystem-stamp tcosify-stamp
	make update-stamp

update-stamp:
	@echo "[1m Target: Installing packages from PACKAGES list and updating the filesystem[0m"
	-rm -f clean-stamp compressed-stamp
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get update; apt-get install -y --force-yes --no-install-recommends $(PACKAGES); apt-get dist-upgrade -y --force-yes --no-install-recommends ; apt-get autoremove" 
	for debFile in Sources/$(EXTRAS); do ln -nf $$debFile Filesystem/tmp/ ; done
	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -i /tmp/*.deb ; rm -rf /tmp/*.deb"
	touch $@

clean: filesystem-stamp update-stamp 
	make clean-stamp

clean-stamp: ./Scripts/TCOS.tcosify-clean
	@echo "[1m Target: Clean up the filesystem[0m"
	-sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-clean
	touch $@

compressed: filesystem-stamp tcosify-stamp update-stamp clean-stamp kernel-install-stamp
	make compressed-stamp

compressed-stamp:
	@echo "[1m Target: Create the base.sfs container[0m"
	-mkdir -p Image
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c 'echo -e "openthinclient OS version 2.x\nbuild: `date`\nbased on and credits to" > /etc/issue; cat /etc/issue.debian >> /etc/issue'
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c 'echo -e "openthinclient OS version 2.x\nbuild: `date`\nbased on and credits to Debian" > /etc/motd; cat /etc/motd.debian >> /etc/motd'
	nice -10 ionice -c 3 sudo mksquashfs Filesystem Image/base.sfs -noappend -always-use-fragments -comp xz 
	touch $@

kernel: 
	make kernel-stamp

kernel-stamp: ./Scripts/TCOS.kernel
	@echo "[1m Target: Build the kernel[0m"
	rm -f kernel-install-stamp
	./Scripts/TCOS.kernel
	touch $@

kernel-install: filesystem-stamp kernel-stamp
	make kernel-install-stamp

kernel-install-stamp: Scripts/LINBO.chroot kernel-stamp
	@echo "[1m Target: Install the kernel[0m"
	-mkdir -p Image/boot/syslinux
	for debFile in Kernel/linux-image-$(KVERS)*.deb Kernel/linux-headers-$(KVERS)*.deb ; do ln -nf $$debFile Filesystem/tmp/ ; done
	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -l libncursesw5 | grep -q '^i' || { apt-get update; apt-get install libncursesw5; } ; apt-get --purge remove -y linux-headers-\* linux-image-\*; dpkg -i /tmp/linux-*$(KVERS)*.deb; rm -rf /tmp/*.deb"
	[ -r Filesystem/boot/vmlinuz-$(KVERS)* ] && cp -uv  Filesystem/boot/vmlinuz-$(KVERS)* Image/boot/syslinux/linux || true
	touch $@

busybox: Sources/busybox.config Sources/busybox
	make busybox-stamp 

busybox-stamp:
	@echo "[1m Target: Create the busybox[0m"
	cp Sources/busybox.config Sources/busybox/.config
	cd Sources/busybox && \
	$(X86) make install
	touch $@

initrd: busybox-stamp
	make initrd-stamp

initrd-stamp:
	@echo "[1m Target: Create the initrd[0m"
	-mkdir -p Image/boot/syslinux
	( cd Initrd && find . | sudo cpio -H newc -ov | gzip -9v ) > Image/boot/syslinux/initrd.gz
	touch $@



##################################################
# Install-Targets

local-test: all 
	make local-test-stamp

local-test-stamp:
	@echo "[1m Target: Copy base.sfs, kernel, etc. to local paths for testing.[0m"
	rsync Image/boot/syslinux/linux     $(LOCAL_TEST_PATH)/tftp/vmlinuz
	rsync Image/boot/syslinux/initrd.gz $(LOCAL_TEST_PATH)/tftp/initrd.img
	rsync Image/base.sfs           $(LOCAL_TEST_PATH)/sfs/base.sfs
	touch $@

package-prepare: all 
	make package-prepare-stamp

package-prepare-stamp:
	@echo "[1m Target: Copy base.sfs, kernel, etc. to package build folder.[0m"
	rsync Image/boot/syslinux/linux     $(BASE_PACKAGE_PATH)/tftp/vmlinuz
	rsync Image/boot/syslinux/initrd.gz $(BASE_PACKAGE_PATH)/tftp/initrd.img
	rsync Image/base.sfs           $(BASE_PACKAGE_PATH)/sfs/base.sfs
	touch $@
