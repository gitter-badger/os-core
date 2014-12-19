#!/usr/bin/make -f
# Makefile for TCOS
# # (C) Steffen Hoenig <s.hoenig@openthinclient.com> 2013, 2014
# # (C) Jörn Frenzel <j.frenzel@openthinclient.com> 2013, 2014
# # License: GPL V2
#
#
SHELL := /bin/bash
HOST_ARCH := $(shell file /sbin/fdisk)

ifeq (80386,$(findstring 80386,$(HOST_ARCH)))
        HOST_ARCH=i386
endif
ifeq (x86-64,$(findstring x86-64,$(HOST_ARCH)))
        HOST_ARCH=x86_64
endif

BUSYBOX_VERSION = 1.22.1
DEB_MIRROR = http://http.debian.net/debian
TARGET_KERNEL := 3.2.0-4-486
TARGET_PACKAGES := dialog apt-utils libpam-ldap alsa-utils aptitude atril ca-certificates cifs-utils console-data console-tools coreutils dbus dbus-x11 dconf-tools devilspie devilspie2 dos2unix dosfstools e2fsprogs eject engrampa eom ethtool file flashplugin-nonfree fontconfig gdevilspie gvfs gvfs-backends hdparm htop iceweasel iceweasel-l10n-de iceweasel-l10n-es-ar iceweasel-l10n-es-cl iceweasel-l10n-es-es iceweasel-l10n-es-mx iceweasel-l10n-fr iceweasel-l10n-uk iproute iputils-ping ipython kmod ldap-utils less libacsccid1 libccid libglib2.0-bin libgtk2.0-bin libgtk-3-bin libmotif4 libpopt0 libqt4-qt3support libqt4-sql libssl1.0.0 libstdc++5 libx11-6 lightdm lightdm-gtk-greeter man marco mc mozo net-tools nfs-common ntp numlockx openssh-client openssh-server pciutils pcsc-tools pluma python python-gconf python-gtk2 python-ldap python-xdg rdesktop rsync screen smplayer spice-client sudo syslog-ng tcpdump ttf-dejavu udev usbip usbutils util-linux vim vim-tiny wget x11vnc  xdg-utils xfonts-base xinetd xinit zenity caja mate-utils-common mate-utils mate-media-gstreamer pulseaudio pavucontrol strace fxcyberjack libifd-cyberjack6 xtightvncviewer dnsutils dmidecode lshw hwinfo libsasl2-modules libsasl2-modules-gssapi-mit libxerces-c3.1 libcurl3 libwebkitgtk-1.0-0 libgssglue1
TARGET_PACKAGES_BACKPORTS := mate-applets mate-desktop mate-media mate-screensaver mate-session-manager mate-system-monitor mate-themes
TARGET_PACKAGES_FGLRX := fglrx-modules-dkms fglrx-driver glx-alternative-fglrx glx-alternative-mesa glx-diversions xvba-va-driver amd-opencl-icd libfglrx libgl1-fglrx-glx  libitm1 libfglrx-amdxvba1 ocl-icd-libopencl1 amd-opencl-icd
TARGET_PACKAGES_BUSYBOXBUILD := build-essential fakeroot kernel-package bc git cpio distcc dkms wget ca-certificates
TARGET_PACKAGES_EXTERNAL := openthinclient-icon-theme_1-1_all.deb libssl0.9.8_0.9.8o-4squeeze14_i386.deb libccid_1.4.7-1~tcos20+1_i386.deb pcscd_1.8.11-3~tcos20+3_i386.deb libpcsclite1_1.8.11-3~tcos20+3_i386.deb libpcsclite-dev_1.8.11-3~tcos20+3_i386.deb

help:
	@echo "^[[1mWELCOME TO THE TCOS BUILD SYSTEM"
	@echo ""
	@echo "make all			Metatarget: create the whole system"
	@echo "make local-test          Metatarget: + copy everthing to local test server"
	@echo "make package-prepare     Metatarget: + copy everthing to package build directory"
	@echo ""
	@echo "make kernel              (Re-)Build Kernel packages"
	@echo "make kernel-install      (Re-)Install Kernel packages"
	@echo "make initrd              (Re-)Build Initramfs"
	@echo "make chroot              Work inside Filesystem"
	@echo "make filesystem          Bootstrap and fill the TCOS ./Filesystem directory"
	@echo "make update              Install or update required packages in TCOS ./Filesystem"
	@echo "make compressed          Compress base filesystem image."
	@echo "make distclean           Remove all resources that can be recreated."
	@echo
	@echo "Don't worry about the sequence of build commands, this Makefile will tell you"
	@echo "what to do first, in case anything is missing."
	@echo
	@echo "Have a lot of fun. ;-)"
	@echo "^[[0m"

filesystem:
	make $@-stamp
filesystem-stamp:
	@echo "^[[1m Target filesystem-stamp: Creating an initial filesystem^[[0m"
	-rm -f tcosify-stamp update-stamp clean-stamp
	# The script TCOS.mkfilesystem also creates the Bbox-build-chroot
	./Scripts/TCOS.mkfilesystem $(DEB_MIRROR)
	@touch $@

busybox:
	make $@-stamp
busybox-stamp:Sources/busybox.config filesystem-stamp
	@echo "^[[1m Target busybox-stamp: Create the busybox^[[0m"
	test -r Sources/busybox/Makefile || \
	    (cd Sources && \
	    wget -O - http://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2  | tar -xjf - && \
	    rm -rf busybox && \
	    mv busybox-$(BUSYBOX_VERSION) busybox)
	# get config in place
	sudo cp Sources/busybox.config Sources/busybox/.config
	# needs to be deleted later on!
	-sudo mkdir Filesystem/build
	sudo mount --bind . Filesystem/build
	# open the Filesystem and install the development tools temporarily
	sudo Scripts/LINBO.chroot Filesystem ro /bin/bash -c "apt-get install -y --force-yes $(TARGET_PACKAGES_BUSYBOXBUILD); cd /build/Sources/busybox; make clean; make install"
	#clean it up
	sudo umount Filesystem/build
	sudo rm -rf Filesystem/build
	touch $@

tcosify:
	make $@-stamp
tcosify-stamp:filesystem-stamp
	@echo "^[[1m Target tcosify-stamp: Applying TCOS specific changes^[[0m"
	Scripts/LINBO.apply-configs Sources/tcos Filesystem
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "ln -snf /bin/bash /bin/sh;"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "[ ! -f  /etc/issue.debian ] && cp /etc/issue /etc/issue.debian;" 
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "[ ! -f  /etc/motd.debian ] && cp /etc/motd /etc/motd.debian;"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-chroot
	touch $@

update:
	make $@-stamp
update-stamp:tcosify-stamp
	@echo "^[[1m Target update-stamp: Installing packages from TARGET_PACKAGES list and updating the filesystem ^[[0m"
	-rm -f clean-stamp compressed-stamp
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get update; apt-get install -y --force-yes --no-install-recommends wget sudo"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends $(TARGET_PACKAGES)"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends  -t wheezy-backports $(TARGET_PACKAGES_BACKPORTS)"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get dist-upgrade -y --force-yes --no-install-recommends ; apt-get autoremove"
	for debFile in $(TERGET_PACKAGES_EXTERNAL); do ln -nf Packages/$$debFile Filesystem/tmp/$$debFile ; done
	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -i /tmp/*.deb ;"
	touch $@

kernel:
	make $@-stamp
kernel-stamp:update-stamp
	@echo "^[[1m Target kernel-install-stamp: Install the kernel^[[0m"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends linux-image-$(TARGET_KERNEL)"
	touch $@

initrd:
	make $@-stamp
initrd-stamp:busybox-stamp kernel-stamp Sources/modules.list
	DEST_DIR=Initrd/lib/modules/ KERNELDIR=Filesystem/lib/modules/$(TARGET_KERNEL)/  Scripts/TCOS.copy_modules
	( cd Initrd && find . | fakeroot cpio -H newc -ov | xz -9 --format=lzma > ../Image/boot/syslinux/initrd.xz )
	touch $@

clean:
	make $@-stamp
clean-stamp: initrd-stamp
	@echo "^[[1m Target clean-stamp: Clean up the filesystem^[[0m"
	-rm -f kernel-install-stamp
	-sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get --purge remove -y linux-headers-\* $(PACKAGES_COMMERCIAL_BUILD); apt-get autoremove"
	-sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-clean
	-sudo rm -f Filesystem/boot/*
	touch $@
compressed:
	make $@-stamp
compressed-stamp: clean-stamp
	@echo "^[[1m Target compressed-stamp: Create the base.sfs container^[[0m"
	-mkdir -p Image
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c 'echo -e "openthinclient OS base $(BASE_VERSION) \nbuild: `date`\nbased on and credits to" > /etc/issue; cat /etc/issue.debian >> /etc/issue'
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c 'echo -e "openthinclient OS base $(BASE_VERSION) \nbuild: `date`\nbased on and credits to Debian" > /etc/motd; cat /etc/motd.debian >> /etc/motd'
	nice -10 ionice -c 3 sudo XZ_OPT="-6 -t 2" mksquashfs Filesystem Image/base.sfs -noappend -always-use-fragments -comp xz
	touch $@
