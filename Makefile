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

DEB_MIRROR = http://otc-dd-01/debian
TARGET_KERNEL := linux-image-3.2.0-4-486
TARGET_PACKAGES := dialog apt-utils libpam-ldap alsa-utils aptitude atril ca-certificates cifs-utils console-data console-tools coreutils dbus dbus-x11 dconf-tools devilspie devilspie2 dos2unix dosfstools e2fsprogs eject engrampa eom ethtool file flashplugin-nonfree fontconfig gdevilspie gvfs gvfs-backends hdparm htop iceweasel iceweasel-l10n-de iceweasel-l10n-es-ar iceweasel-l10n-es-cl iceweasel-l10n-es-es iceweasel-l10n-es-mx iceweasel-l10n-fr iceweasel-l10n-uk iproute iputils-ping ipython kmod ldap-utils less libacsccid1 libccid libglib2.0-bin libgtk2.0-bin libgtk-3-bin libmotif4 libpopt0 libqt4-qt3support libqt4-sql libssl1.0.0 libstdc++5 libx11-6 lightdm lightdm-gtk-greeter man marco mate-applets mate-desktop mate-media mate-screensaver mate-session-manager mate-system-monitor mate-themes mc mozo net-tools nfs-common ntp numlockx openssh-client openssh-server pciutils  pluma python python-gconf python-gtk2 python-ldap python-xdg rdesktop rsync screen smplayer spice-client sudo syslog-ng tcpdump ttf-dejavu udev usbip usbutils util-linux vim vim-tiny wget x11vnc  xdg-utils xfonts-base xinetd xinit zenity caja mate-utils-common mate-utils mate-media-gstreamer pulseaudio pavucontrol strace fxcyberjack libifd-cyberjack6 xtightvncviewer dnsutils dmidecode lshw hwinfo libsasl2-modules libsasl2-modules-gssapi-mit libxerces-c3.1 libcurl3 libwebkitgtk-1.0-0 libgssglue1
TARGET_PACKAGES_EXTERNAL := fglrx-modules-dkms fglrx-driver glx-alternative-fglrx glx-alternative-mesa glx-diversions xvba-va-driver amd-opencl-icd libfglrx libgl1-fglrx-glx  libitm1 libfglrx-amdxvba1 ocl-icd-libopencl1 amd-opencl-icd

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
filesystem-stamp: ./Scripts/TCOS.mkfilesystem
	@echo "^[[1m Target filesystem-stamp: Creating an initial filesystem^[[0m"
	-rm -f tcosify-stamp update-stamp clean-stamp
	# The script TCOS.mkfilesystem also creates the Bbox-build-chroot
	./Scripts/TCOS.mkfilesystem $(DEB_MIRROR)
	touch $@

busybox: Sources/busybox.config Sources/busybox filesystem-stamp
	make $@-stamp
busybox-stamp:
	@echo "^[[1m Target busybox-stamp: Create the busybox^[[0m"
