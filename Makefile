#!/usr/bin/make -f
# Makefile for TCOS
# (C) Steffen Hoenig <s.hoenig@openthinclient.com> 2013, 2014
# (C) Jörn Frenzel <j.frenzel@openthinclient.com> 2013, 2014
# License: GPL V2

SHELL := /bin/bash

# make filesystem OK
# make kernel OK
# make update OK, pcsc-tools machen bei Installation dumm
# make initrd OK
# make commercial-module OK

# Define which kernel to download and compile for TCOS
export KVERS	  = 3.14.5
export BUSYBOX_VERSION = 1.22.1
export X86	  = CFLAGS="-m32" LDFLAGS="-m32" ARCH="i386"
export X86_64	  = CFLAGS="-m64" LDFLAGS="-m64" ARCH="x86_64"
#export BASE_PACKAGE_PATH  = Base/base-2.0/debian/base
export BASE_PACKAGE_PATH  = root@otc-dd-dev2:/develop/Base/base-2.0/
export LOCAL_TEST_PATH	= root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root/
export DEB_MIRROR = http://otc-dd-01/debian
export CPU_CORES = 4
export ARCH	  = i386
export BASE_VERSION ?= 2.0-xx(minor_unknown)


# VARIABLE  = value --> Normal setting of a variable - values within it are recursively expanded when the variable is used, not when it's declared
# VARIABLE ?= value --> Setting of a variable only if it doesn't have a value
# VARIABLE := value --> Setting of a variable with simple expansion of the values inside - values within it are expanded at declaration time.
# VARIABLE += value --> Appending the supplied value to the existing val

# Have package list in alphabetical order for better human reading. Cleanup dups.
# for package in one two three; do echo $package; done | sort -u | sed ':a;N;$!ba;s/\n/ /g'

# takes round about 30 minutes to install
# 
# These are the packages from debian wheezy 
#
export PACKAGES = dialog libpam-ldap alsa-utils aptitude atril ca-certificates cifs-utils console-data console-tools coreutils dbus dbus-x11 dconf-tools devilspie devilspie2 dos2unix dosfstools e2fsprogs eject engrampa eom ethtool file flashplugin-nonfree fontconfig gdevilspie gvfs gvfs-backends hdparm htop iceweasel iceweasel-l10n-de iceweasel-l10n-es-ar iceweasel-l10n-es-cl iceweasel-l10n-es-es iceweasel-l10n-es-mx iceweasel-l10n-fr iceweasel-l10n-uk iproute iputils-ping ipython kmod ldap-utils less libacsccid1 libccid libdrm2 libdrm-intel1 libdrm-nouveau1a libdrm-radeon1 libgl1-mesa-dri libgl1-mesa-dri-experimental libgl1-mesa-glx libglib2.0-bin libgtk2.0-bin libgtk-3-bin libmotif4 libpopt0 libqt4-qt3support libqt4-sql libssl1.0.0 libstdc++5 libx11-6 lightdm lightdm-gtk-greeter man marco mate-applets mate-desktop mate-media mate-screensaver mate-session-manager mate-system-monitor mate-themes mc mozo net-tools nfs-common ntp numlockx openssh-client openssh-server pciutils  pluma python python-gconf python-gtk2 python-ldap python-xdg rdesktop rsync screen smplayer spice-client sudo syslog-ng tcpdump ttf-dejavu udev usbip usbutils util-linux vim vim-tiny wget x11vnc  xdg-utils xfonts-base xinetd xinit zenity caja mate-utils-common mate-utils mate-media-gstreamer pulseaudio pavucontrol strace fxcyberjack libifd-cyberjack6 xtightvncviewer dnsutils dmidecode lshw hwinfo libsasl2-modules libsasl2-modules-gssapi-mit libxerces-c3.1 libcurl3 libwebkitgtk-1.0-0 libgssglue1

# mate-media-pulse causes mate-mixer to crash


##################################################################
# These are the packages from debian sid/unstable. We need some newer stuff in some cases.  
#
export PACKAGES_UNSTABLE = mesa-vdpau-drivers vdpauinfo x11-xserver-utils xorg xserver-xorg xserver-xorg-core xserver-xorg-input-evdev xserver-xorg-input-kbd xserver-xorg-input-mouse xserver-xorg-video-all xserver-xorg-video-intel xserver-xorg-video-nouveau xserver-xorg-video-openchrome xserver-xorg-video-radeon xserver-xorg-video-ati xserver-xorg-video-geode xserver-xorg-video-glide xserver-xorg-video-amd libgl1-mesa-dri arandr libglew1.10 libvdpau1 freerdp-X11 xserver-xorg-input-multitouch xserver-xorg-input-mutouch xserver-xorg-input-wacom mesa-utils libc6-dev


##################################################################
# These are the packages we pull from debian backports.	 
#
export PACKAGES_BACKPORTS = firmware-linux firmware-linux-free firmware-linux-nonfree 

##################################################################
# These are the packages we install inside the busybox buildsystem
#
export PACKAGES_BUSYBOXBUILD = build-essential fakeroot kernel-package bc git cpio distcc dkms wget ca-certificates 

##################################################################
# Some packages are handmade or handpicked by the otc-team
#
export EXTRAS = openthinclient-icon-theme_1-1_all.deb libssl0.9.8_0.9.8o-4squeeze14_i386.deb libccid_1.4.7-1~tcos20+1_i386.deb pcscd_1.8.11-3~tcos20+3_i386.deb libpcsclite1_1.8.11-3~tcos20+3_i386.deb	libpcsclite-dev_1.8.11-3~tcos20+3_i386.deb  
# some packages need to be after our deb packages
export PACKAGES_AFTER_EXTRAS = pcsc-tools


##################################################################
# Some packages are temporarily used to compile non-gpl stuff.
# These Pakages will be uninstalled when their job is done.
#
# Keep in mind to use the same compiler version for modules as for
# kernel build
#
#export PACKAGES_COMMERCIAL_BUILD = cpp-4.7 dkms gcc-4.7 make patch
export PACKAGES_COMMERCIAL_BUILD = build-essential

# do we really need this packages? libgcc-4.7-dev nvidia-installer-cleanup

##################################################################
# These are proprietary packages for some special hardware. These 
# packages need to be installed in a finaly finished  Filesystem 
# with kernel-headers within.
# used from SID/unstable
#
export PACKAGES_COMMERCIAL = fglrx-modules-dkms fglrx-driver glx-alternative-fglrx glx-alternative-mesa glx-diversions xvba-va-driver amd-opencl-icd libfglrx libgl1-fglrx-glx	libcilkrts5 libasan1 libatomic1 libubsan0 libitm1 libfglrx-amdxvba1 ocl-icd-libopencl1 amd-opencl-icd

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
	@echo "make filesystem		Bootstrap and fill the TCOS ./Filesystem directory"
	@echo "make busybox-build-chroot	prepare the change root to build a 32-Bit busybox"
	@echo "make update		Install or update required packages in TCOS ./Filesystem"
	@echo "make compressed		Compress base filesystem image."
	@echo "make distclean		Remove all resources that can be recreated."
	@echo
	@echo "Don't worry about the sequence of build commands, this Makefile will tell you"
	@echo "what to do first, in case anything is missing."
	@echo
	@echo "Have a lot of fun. ;-)"
	@echo "[0m"

# Meta-Targets
#
distclean:
	sudo rm -rf Filesystem/* Image/boot/syslinux/vmlinuz* Image/boot/syslinux/initrd.gz Kernel/aufs-linux-* *-stamp 
	sudo find ./Initrd -xdev -samefile Initrd/bin/busybox -delete || true

chroot: filesystem-stamp ./Scripts/LINBO.chroot
	rm -f clean-stamp
	sudo Scripts/LINBO.chroot ./Filesystem

all: 
	make initrd 
	make final-clean
	make compressed 
#	-rm -f kernel-install-stamp 

# Build-Targets
#
filesystem: 
	make filesystem-stamp

filesystem-stamp: ./Scripts/TCOS.mkfilesystem
	@echo "[1m Target filesystem-stamp: Creating an initial filesystem[0m"
	-rm -f tcosify-stamp update-stamp clean-stamp
	./Scripts/TCOS.mkfilesystem $(DEB_MIRROR)
	touch $@

busybox-build-chroot: filesystem-stamp
	make busybox-build-chroot-stamp 

busybox-build-chroot-stamp: Scripts/LINBO.chroot filesystem-stamp
        # the initial content of Bbox-build-chroot is a copy of folder Filesystem
	@echo "[1m Target busybox-build-chroot-stamp: Create a changeroot to build busybox inside[0m"
	sudo Scripts/LINBO.chroot Bbox-build-chroot /bin/bash -c "apt-get install -y --force-yes --no-install-recommends  $(PACKAGES_BUSYBOXBUILD)"
	sudo Scripts/LINBO.chroot Bbox-build-chroot /bin/bash -c "ln -sf /bin/bash /bin/sh; mkdir /busybox /Initrd"
	sudo Scripts/LINBO.chroot Bbox-build-chroot /bin/bash -c  "cd /usr/bin; ln -s gcc-4.7 i486-linux-gcc; ln -s ar i486-linux-ar; ln -s strip i486-linux-strip"
	touch $@ 

busybox: Sources/busybox.config Sources/busybox busybox-build-chroot-stamp
	make busybox-stamp
	-rm initrd-stamp 

busybox-stamp:
	@echo "[1m Target busybox-stamp: Create the busybox[0m"
	# check if there is already a busybox source and download/extract it if not
	test -r Sources/busybox/Makefile || \
		(cd Sources && \
		wget -O - http://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2  | tar -xjf - && \
		rm -rf busybox && \
		mv busybox-$(BUSYBOX_VERSION) busybox)

	# get config in place
	sudo cp Sources/busybox.config Sources/busybox/.config

	# just to be sure, unmount it
	-sudo umount Bbox-build-chroot/busybox &> /dev/null
	-sudo umount Bbox-build-chroot/Initrd &> /dev/null

	# we need to bind mount it, softlinks won't work
	sudo mount -o bind Sources/busybox Bbox-build-chroot/busybox

	-mkdir -p Initrd
	sudo mount -o bind Initrd Bbox-build-chroot/Initrd

	# let's compile
	sudo Scripts/LINBO.chroot Bbox-build-chroot /bin/bash -c "cd /busybox; make clean; $(X86) make -j$(CPU_CORES) install"

	# get rid of the bind mounts
	sudo umount Bbox-build-chroot/busybox &> /dev/null
	sudo umount Bbox-build-chroot/Initrd &> /dev/null
	touch $@


tcosify: filesystem-stamp 
	make tcosify-stamp

tcosify-stamp: ./Scripts/LINBO.chroot
	@echo "[1m Target tcosify-stamp: Applying TCOS specific changes[0m"
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
	@echo "[1m Target update-stamp: Installing packages from PACKAGES list and updating the filesystem[0m"
	-rm -f clean-stamp compressed-stamp
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get update; apt-get install -y --force-yes --no-install-recommends wget sudo"	
	# sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "wget -qO - http://mirror1.mate-desktop.org/debian/mate-archive-keyring.gpg | sudo apt-key add -"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends $(PACKAGES)"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends -t unstable $(PACKAGES_UNSTABLE)"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends  -t wheezy-backports $(PACKAGES_BACKPORTS)"

	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get dist-upgrade -y --force-yes --no-install-recommends ; apt-get autoremove"
	for debFile in $(EXTRAS); do ln -nf Packages/$$debFile Filesystem/tmp/$$debFile ; done
	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -i /tmp/*.deb ; rm -rf /tmp/*.deb"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends $(PACKAGES_AFTER_EXTRAS)"
	touch $@

kernel: busybox-build-chroot-stamp
	make kernel-stamp

kernel-stamp: ./Scripts/TCOS.kernel 
	@echo "[1m Target kernel-stamp: Build the kernel[0m"
	rm -f kernel-install-stamp compressed-stamp 

	# just to be sure, unmount it
	-sudo umount Bbox-build-chroot/Kernel &> /dev/null; sudo umount Bbox-build-chroot/Sources &> /dev/null

	# we need to bind mount it, softlinks won't work
	-sudo mkdir -p Bbox-build-chroot/Sources Bbox-build-chroot/Kernel
	sudo mount -o bind Sources Bbox-build-chroot/Sources
	sudo mount -o bind Kernel Bbox-build-chroot/Kernel

	# Let's compile inside the busybox changeroot.
	# This ensures to have the kernel compiled with the systems libs and compilers
	# and gives us a better 32 bit environment.
	sudo CPU_CORES=$(CPU_CORES) KVERS=$(KVERS) ARCH=$(ARCH) Scripts/LINBO.chroot Bbox-build-chroot /bin/bash < Scripts/TCOS.kernel

	# get rid of the bind mounts
	sudo umount Bbox-build-chroot/Kernel &> /dev/null; sudo umount Bbox-build-chroot/Sources &> /dev/null

	-mkdir -p Image/boot/syslinux
	-cp Kernel/aufs-linux-$(KVERS)_normal/arch/$(ARCH)/boot/bzImage Image/boot/syslinux/vmlinuz
	-cp Kernel/aufs-linux-$(KVERS)_non-pae/arch/$(ARCH)/boot/bzImage Image/boot/syslinux/vmlinuz_non-pae
	-cp Kernel/aufs-linux-$(KVERS)_transmeta/arch/$(ARCH)/boot/bzImage Image/boot/syslinux/vmlinuz_transmeta

	touch $@

kernel-install: update-stamp kernel-stamp
	make kernel-install-stamp

kernel-install-stamp: Scripts/LINBO.chroot 
	@echo "[1m Target kernel-install-stamp: Install the kernel[0m"
	-rm -f compressed-stamp commercial-module-stamp final-clean-stamp
	-mkdir -p Image/boot/syslinux
	for debFile in Kernel/linux-image-$(KVERS)*.deb Kernel/linux-headers-$(KVERS)*.deb ; do sudo ln -nf $$debFile Filesystem/tmp/ ; done
	sudo Scripts/LINBO.chroot Filesystem bash -c "dpkg -l libncursesw5 | grep -q '^i' || { apt-get update; apt-get install libncursesw5; } ; dpkg -i /tmp/linux-*$(KVERS)*.deb; rm -rf /tmp/*.deb"
	touch $@


commercial-module: kernel-install-stamp
	make commercial-module-stamp

commercial-module-stamp: 
	@echo "[1m Target commercial-module-stamp: Build commercial module inside the filsystem[0m"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends $(PACKAGES_COMMERCIAL_BUILD)"
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get install -y --force-yes --no-install-recommends -t unstable $(PACKAGES_COMMERCIAL)"
	#### FGLRX
	# This script ensures, that the fglrx kernel module is build for all kernel versions.
	# The package itself doesn't do this job right.
	sudo KVERS=$(KVERS) Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.fglrx_install 

	# This script compiles and installs the usbrdr kernel modules
	sudo KVERS=$(KVERS) Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.usbrdr_install

	#### NVIDIA
	# -mkdir -p Filesystem/tmp/NvidiaSources NvidiaModules Filesystem/tmp/NvidiaModules
	# -sudo umount Filesystem/tmp/NvidiaSources &> /dev/null
	# -sudo umount Filesystem/tmp/NvidiaModules &> /dev/null
	# sudo mount -o bind Sources/Nvidia Filesystem/tmp/NvidiaSources
	# sudo mount -o bind NvidiaModules Filesystem/tmp/NvidiaModules
	# sudo KVERS=$(KVERS) Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.nvidia_install
	# -sudo umount Filesystem/tmp/NvidiaSources &> /dev/null
	# -sudo umount Filesystem/tmp/NvidiaModules &> /dev/null
	touch $@

initrd: busybox-stamp
	make initrd-stamp

initrd-stamp:
	@echo "[1m Target initrd-stamp: Create the initrd[0m"
	-mkdir -p Image/boot/syslinux
	# *** CAVEAT ***
	# If xz is used for initrd compression, lzma format must be used. Either pxelinux (bootloader) 
	# or the kernel itself can't handle other formats.
	( cd Initrd && find . | fakeroot cpio -H newc -ov | xz -9 --format=lzma > ../Image/boot/syslinux/initrd.xz )
	touch $@

clean: commercial-module-stamp 
	make clean-stamp

clean-stamp: ./Scripts/TCOS.tcosify-clean 
	@echo "[1m Target clean-stamp: Clean up the filesystem[0m"
	-sudo Scripts/LINBO.chroot Filesystem /bin/bash < Scripts/TCOS.tcosify-clean
	touch $@

final-clean: clean-stamp
	make final-clean-stamp

final-clean-stamp:
	@echo "[1m Target final-clean: Clean all useless stuff before shipping.[0m"
	# This target should run just before a new base-package is finnaly build.
	# Get rid of stuff you don't really need after the build process
	@echo "[1m Target final-clean-stamp: Remove [0m"
	-sudo rm -f Filesystem/boot/*
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c "apt-get --purge remove -y linux-headers-\* $(PACKAGES_COMMERCIAL_BUILD)"
	touch $@


#compressed: filesystem-stamp update-stamp kernel-install-stamp commercial-module-stamp clean-stamp
compressed: final-clean
	make compressed-stamp

compressed-stamp: 
	@echo "[1m Target compressed-stamp: Create the base.sfs container[0m"
	-mkdir -p Image
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c 'echo -e "openthinclient OS base $(BASE_VERSION) \nbuild: `date`\nbased on and credits to" > /etc/issue; cat /etc/issue.debian >> /etc/issue'
	sudo Scripts/LINBO.chroot Filesystem /bin/bash -c 'echo -e "openthinclient OS base $(BASE_VERSION) \nbuild: `date`\nbased on and credits to Debian" > /etc/motd; cat /etc/motd.debian >> /etc/motd'
	nice -10 ionice -c 3 sudo XZ_OPT="-6 -t 2" mksquashfs Filesystem Image/base.sfs -noappend -always-use-fragments -comp xz
	touch $@


##################################################
# Install-Targets

local-test: initrd-stamp compressed-stamp commercial-module-stamp
	make local-test-stamp

local-test-stamp:
	@echo "[1m Target local-test-stamp: Copy base.sfs, kernel, etc. to local paths for testing.[0m"
	rsync Image/boot/syslinux/vmlinuz*     $(LOCAL_TEST_PATH)/tftp/
	rsync Image/boot/syslinux/initrd.xz $(LOCAL_TEST_PATH)/tftp/initrd.img
	rsync Image/*.sfs	    $(LOCAL_TEST_PATH)/sfs/

package-prepare: all 
	make package-prepare-stamp

package-prepare-stamp:
	@echo "[1m Target package-prepare-stamp: Copy base.sfs, kernel, etc. to package build folder.[0m"
	# /usr/src/* and /boot/* are not needed to run a client
	# Target "all" calls target "final-clean". We consider the kernel stuff as removed once
	# we have prepared for packaging.
	 -rm -f kernel-install-stamp 
	rsync Image/boot/syslinux/vmlinuz*     $(BASE_PACKAGE_PATH)/debian/base/tftp/
	rsync Image/boot/syslinux/initrd.xz $(BASE_PACKAGE_PATH)/debian/base/tftp/initrd.img
	rsync Image/base.sfs	       $(BASE_PACKAGE_PATH)/debian/base/sfs/
	# touch $@
