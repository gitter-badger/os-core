#!/usr/bin/make -f
# Makefile for TCOS
# # (C) Steffen Hoenig <s.hoenig@openthinclient.com> 2013-2015
# # (C) Jörn Frenzel <j.frenzel@openthinclient.com> 2013-2015
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
TARGET_ARCH := i386
TOP_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

BASE_VERSION := 2.1
BUSYBOX_VERSION := 1.22.1
DEB_MIRROR := http://http.debian.net/debian
LOCAL_TEST_PATH := $(shell /usr/share/tcos-dev/functions/ini_parser -r ~/.tcosconfig):/opt/openthinclient/server/default/data/nfs/root
TARGET_KERNEL_DEFAULT := 3.14-0.bpo.2-686-pae
TARGET_KERNEL_NONPAE := 3.14-0.bpo.2-486

# run-time packages
#
TARGET_PACKAGES := alsa-utils apt-utils aptitude arandr ca-certificates cifs-utils console-data console-tools coreutils dbus dbus-x11 dconf-tools devilspie devilspie2 dialog dmidecode dnsutils dos2unix dosfstools e2fsprogs ethtool file firmware-linux flashplugin-nonfree fontconfig freerdp-X11 gdevilspie gvfs gvfs-backends htop hwinfo iceweasel iceweasel-l10n-de ipython ldap-utils less libdrm-intel1 libdrm-nouveau1a libdrm-radeon1 libdrm2 libgl1-mesa-dri libgl1-mesa-dri libgl1-mesa-glx libgssglue1 libpam-ldap libsasl2-modules libsasl2-modules-gssapi-mit libssl1.0.0 libstdc++5 libvdpau1 libwebkitgtk-1.0-0 libx11-6 libxerces-c3.1 lightdm lightdm-gtk-greeter locales locales-all lshw ltrace mc mesa-utils nfs-common ntp numlockx openssh-client openssh-server pciutils python-gconf python-gtk2 python-ldap python-xdg rdesktop rsync smplayer strace sudo syslog-ng ttf-dejavu udhcpc usbutils util-linux vim wget x11-xserver-utils x11vnc xdg-utils xfonts-base xinetd xorg xserver-xorg xserver-xorg-core xserver-xorg-input-evdev xserver-xorg-input-multitouch xserver-xorg-input-mutouch xserver-xorg-input-wacom xserver-xorg-video-ati xserver-xorg-video-fbdev xserver-xorg-video-geode xserver-xorg-video-intel xserver-xorg-video-modesetting xserver-xorg-video-nouveau xserver-xorg-video-openchrome xserver-xorg-video-radeon xserver-xorg-video-savage xserver-xorg-video-vesa xtightvncviewer zenity
TARGET_PACKAGES_BACKPORTS := atril caja engrampa eom glx-alternative-fglrx glx-alternative-nvidia glx-alternative-mesa libfglrx libgl1-nvidia-glx libgl1-nvidia-legacy-173xx-glx mate-applets mate-desktop mate-media mate-screensaver mate-session-manager mate-system-monitor mate-themes nvidia-alternative nvidia-alternative-legacy-173xx nvidia-driver-bin nvidia-vdpau-driver pluma xserver-xorg-video-nvidia xserver-xorg-video-nvidia-legacy-173xx xvba-va-driver
TARGET_PACKAGES_DEB := openthinclient-icon-theme_1-1_all.deb libssl0.9.8_0.9.8o-4squeeze14_i386.deb libccid_1.4.7-1~tcos20+1_i386.deb libpcsclite1_1.8.11-3~tcos20+3_i386.deb pcscd_1.8.11-3~tcos20+3_i386.deb libpcsclite-dev_1.8.11-3~tcos20+3_i386.deb xserver-xorg-video-chrome9_5.76.52.92-1_i386.deb libfglrx_14.12-1_i386.deb libgl1-fglrx-glx_14.12-1_i386.deb libgl1-fglrx-glx-i386_14.12-1_i386.deb libfglrx-amdxvba1_14.12-1_i386.deb
# build packages
#
TARGET_PACKAGES_BUSYBOXBUILD := make gcc bzip2 libc6-dev perl
TARGET_PACKAGES_BACKPORTS_DKMS :=nvidia-kernel-common dkms gcc gcc-4.7 libitm1 make patch nvidia-kernel-dkms nvidia-legacy-173xx-kernel-dkms
TARGET_PACKAGES_DEB_DKMS := via-chrome9-dkms_5.76.52.92-3_all.deb fglrx-modules-dkms_14.12-1_i386.deb

# Meta-Targets
#

all: compressed-stamp base upload
test: compressed-stamp upload-test

chroot:
	@sudo BIND_ROOT=./ Scripts/TCOS.chroot ./Filesystem /bin/bash
chroot-ro:
	@sudo AUFS=1 BIND_ROOT=./ Scripts/TCOS.chroot ./Filesystem /bin/bash
help:
	@echo "[1mWELCOME TO THE TCOS BUILD SYSTEM[0m"
	@echo ""
	@echo "make all		Metatarget: create the whole system"
	@echo ""
	@echo "make filesystem		Bootstrap and fill the TCOS ./Filesystem directory"
	@echo "make busybox		(Re-)Build Busybox"
	@echo "make kernel		(Re-)Build Kernel packages"
	@echo "make initrd		(Re-)Build Initramfs"
	@echo "make chroot		Work inside Filesystem"
	@echo "make update		Install or update required packages in TCOS ./Filesystem"
	@echo "make compressed		Compress base filesystem image."
	@echo
	@echo "Don't worry about the sequence of build commands, this Makefile will tell you"
	@echo "what to do first, in case anything is missing."
	@echo
	@echo "Have a lot of [36mfun[0m. ;-)"

# Build-Targets
#
filesystem:
	make $@-stamp
filesystem-stamp:
	@echo "[1m Target filesystem-stamp: Creating an initial filesystem[0m"
	-rm -f tcosify-stamp update-stamp kernel-stamp clean-stamp
	TARGET_ARCH=$(TARGET_ARCH) ./Scripts/TCOS.mkfilesystem $(DEB_MIRROR)
	@touch $@

busybox:
	make $@-stamp

busybox-stamp: Sources/busybox.config filesystem-stamp
	@echo "[1m Target busybox-stamp: Create the busybox[0m"
	test -r Sources/busybox/Makefile || \
	    (cd Sources && \
	    wget -O - http://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2  | tar -xjf - && \
	    rm -rf busybox && \
	    mv busybox-$(BUSYBOX_VERSION) busybox)
	# open the Filesystem and install the development tools temporarily
	(test -r Initrd/bin/busybox && test Sources/busybox/.config -ot Initrd/bin/busybox) || \
	    sudo AUFS=1 BIND_ROOT=./ Scripts/TCOS.chroot Filesystem /bin/bash -c \
	    "DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes make gcc bzip2 libc6-dev perl; \
	     cd /TCOS/Sources/busybox; make clean; make install\
	    "
	@touch $@

tcosify:
	make $@-stamp
tcosify-stamp:filesystem-stamp busybox-stamp
	@echo "[1m Target tcosify-stamp: Applying TCOS specific changes[0m"
	-rm -f update-stamp kernel-stamp clean-stamp
	Scripts/LINBO.apply-configs Sources/tcos Filesystem
	sudo BASE_VERSION=$(BASE_VERSION) Scripts/TCOS.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-chroot
	@touch $@

update:
	make $@-stamp
update-stamp:tcosify-stamp
	@echo "[1m Target update-stamp: Installing packages from TARGET_PACKAGES list and updating the filesystem [0m"
	-rm -f clean-stamp
	sudo Scripts/TCOS.chroot Filesystem /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get update"
	sudo Scripts/TCOS.chroot Filesystem /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends -o Dpkg::Options::="--force-confold" $(TARGET_PACKAGES)"
	sudo Scripts/TCOS.chroot Filesystem /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends -t wheezy-backports -o Dpkg::Options::="--force-confold" $(TARGET_PACKAGES_BACKPORTS)"
	sudo BIND_ROOT=./ Scripts/TCOS.chroot Filesystem bash -c "for deb in $(TARGET_PACKAGES_DEB); do dpkg -i /TCOS/Packages/\$$deb; done"
	@touch $@

kernel:
	make $@-stamp
kernel-stamp:update-stamp
	@echo "[1m Target kernel-install-stamp: Install the kernel[0m"
	-sudo mkdir -p Base/base-$(BASE_VERSION)/tftp/
	for kernel in $(TARGET_KERNEL_DEFAULT) $(TARGET_KERNEL_NONPAE); do \
	    sudo BIND_ROOT=./ Scripts/TCOS.chroot Filesystem /bin/bash -c \
	    "apt-get install -y --force-yes -t wheezy-backports linux-image-$$kernel" ; \
	    sudo cp Filesystem/boot/vmlinuz-$$kernel Base/base-$(BASE_VERSION)/tftp/ ; \
	done
	(cd Base/base-$(BASE_VERSION)/debian/base/tftp/; sudo mv vmlinuz-$(TARGET_KERNEL_DEFAULT) vmlinuz)
	(cd Base/base-$(BASE_VERSION)/debian/base/tftp/; sudo mv vmlinuz-$(TARGET_KERNEL_NONPAE) vmlinuz_non-pae)
	@touch $@
driver:
	make $@-stamp
driver-stamp:kernel-stamp
	echo "[1m Target driver-stamp: Compile external modules for the kernel[0m"
	-sudo mkdir -p Driver
	sudo AUFS=1 BIND_ROOT=./ Scripts/TCOS.chroot Filesystem /bin/bash -c "\
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --force-yes --no-install-recommends -t wheezy-backports -o Dpkg::Options::="--force-confold" $(TARGET_PACKAGES_BACKPORTS_DKMS) linux-headers-$(TARGET_KERNEL_DEFAULT) linux-headers-$(TARGET_KERNEL_NONPAE); \
	for deb in $(TARGET_PACKAGES_DEB_DKMS); \
	do \
	   dpkg -i /TCOS/Packages/\$$deb; \
	done; \
	rsync -vaR /lib/modules/*/updates /TCOS/Driver/;"
	@touch $@

initrd:
	make $@-stamp
initrd-stamp:busybox-stamp driver-stamp Sources/modules.list
	for kernel in $(TARGET_KERNEL_DEFAULT) $(TARGET_KERNEL_NONPAE); do \
	    sudo rm -rf Initrd/lib/modules/$$kernel; \
	    sudo BIND_ROOT=./ Scripts/TCOS.chroot Filesystem /bin/bash -c \
	    "DEST_DIR=/TCOS/Initrd \
	    KERNELDIR=/lib/modules/$$kernel \
	    MODULES_LIST=/TCOS/Sources/modules.list \
	    TCOS/Scripts/TCOS.copy_modules"; \
	done
	sudo sh -c  'cd Initrd && find . | fakeroot cpio -H newc -ov | xz -9 --format=lzma > $$OLDPWD/Base/base-$(BASE_VERSION)/debian/base/tftp/initrd.img; cd ..'
	@touch $@

clean:
	make $@-stamp
clean-stamp: initrd-stamp
	@echo "[1m Target clean-stamp: Clean up the filesystem[0m"
	-sudo Scripts/TCOS.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-clean
	@touch $@

compressed: 
	make $@-stamp

compressed-stamp: clean-stamp
	@echo "[1m Target compressed-stamp: Create the base.sfs container[0m"
	-sudo mkdir -p Base/base-$(BASE_VERSION)/sfs/
#	nice -10 ionice -c 3 sudo XZ_OPT="-6 -t 2" mksquashfs Filesystem Base/base-$(BASE_VERSION)/debian/base/sfs/base.sfs -noappend -always-use-fragments -comp xz
	nice -10 ionice -c 3 sudo mksquashfs Filesystem Base/base-$(BASE_VERSION)/sfs/base.sfs -noappend -always-use-fragments -comp lzo
	@touch $@

# Install-Targets
# todo: upload needs to be more plattform agnostic

base:
	sudo AUFS=1 BIND_ROOT=./ Scripts/TCOS.chroot Filesystem /bin/bash -c "echo \"deb http://packages.openthinclient.org/openthinclient/v2/devel ./\" > /etc/apt/sources.list.d/tcos.list; apt-get update; \
	    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends tcos-dev; \
	    cd TCOS/Base/base-$(BASE_VERSION); \
	    dch -l autobuild \"autobuild as of `date`\"; \
	    tcos build ."
	touch $@-stamp

upload:
	tcos upload Base/base_$(shell sed -n '2p' Base/base-2.1/debian/base/DEBIAN/control | cut -d " " -f 2)_$(TARGET_ARCH).deb

upload-test:
	@echo "[1m Target test: Copy base.sfs, kernel, etc. to development server for testing.[0m"
	rsync Base/base-$(BASE_VERSION)/tftp/vmlinuz*  Base/base-$(BASE_VERSION)/tftp/initrd* $(LOCAL_TEST_PATH)/tftp/
	rsync Base/base-$(BASE_VERSION)/sfs/*.sfs     $(LOCAL_TEST_PATH)/sfs/

