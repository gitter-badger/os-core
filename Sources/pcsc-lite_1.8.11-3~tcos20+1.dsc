Format: 3.0 (quilt)
Source: pcsc-lite
Binary: pcscd, libpcsclite-dev, libpcsclite1-dbg, libpcsclite1
Architecture: any
Version: 1.8.11-3~tcos20+1
Maintainer: Ludovic Rousseau <rousseau@debian.org>
Homepage: http://pcsclite.alioth.debian.org/
Standards-Version: 3.9.5
Vcs-Browser: http://anonscm.debian.org/viewvc/collab-maint/deb-maint/pcsc-lite/trunk/
Vcs-Svn: svn://anonscm.debian.org/collab-maint/deb-maint/pcsc-lite/trunk
Build-Depends: debhelper (>= 9), flex, dh-autoreconf, libudev-dev [linux-any], libusb2-dev [kfreebsd-any], pkg-config, dpkg-dev (>= 1.16.1~)
Package-List: 
 libpcsclite-dev deb libdevel optional
 libpcsclite1 deb libs optional
 libpcsclite1-dbg deb debug extra
 pcscd deb misc optional
Checksums-Sha1: 
 b72e506978121cde284f8b0b01986df74728dc7a 571837 pcsc-lite_1.8.11.orig.tar.bz2
 06513a4926231700a9a89ee7962fe333c8ce9116 15862 pcsc-lite_1.8.11-3~tcos20+1.debian.tar.gz
Checksums-Sha256: 
 945041c94c53959ae5a767616a4ec5099fe67f549bfd344e8bd0cfe7a3c71ac6 571837 pcsc-lite_1.8.11.orig.tar.bz2
 769496e456013d20d19bdb0a0b62dba88b43ba7b175d92f91059f61b0d64df5c 15862 pcsc-lite_1.8.11-3~tcos20+1.debian.tar.gz
Files: 
 73502ca4ba6526727f9f49c63d805408 571837 pcsc-lite_1.8.11.orig.tar.bz2
 f1753bf82035d2b712670b01cf5e0eee 15862 pcsc-lite_1.8.11-3~tcos20+1.debian.tar.gz
