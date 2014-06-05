Format: 3.0 (quilt)
Source: pcsc-lite
Binary: pcscd, libpcsclite-dev, libpcsclite1-dbg, libpcsclite1
Architecture: any
Version: 1.8.11-3~tcos20+2
Maintainer: Steffen Hoenig <s.hoenig@openthinclient.com>
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
 db9005b596f2988c7fa4362dfe6d4a4624be7950 15782 pcsc-lite_1.8.11-3~tcos20+2.debian.tar.gz
Checksums-Sha256: 
 945041c94c53959ae5a767616a4ec5099fe67f549bfd344e8bd0cfe7a3c71ac6 571837 pcsc-lite_1.8.11.orig.tar.bz2
 b6a3bcfe7811940ec47abc8a47e88753e56515e16f28bf2d3f0bf2e8330cc9a0 15782 pcsc-lite_1.8.11-3~tcos20+2.debian.tar.gz
Files: 
 73502ca4ba6526727f9f49c63d805408 571837 pcsc-lite_1.8.11.orig.tar.bz2
 5a72cb7a0fc71fcf24c2866e403f6827 15782 pcsc-lite_1.8.11-3~tcos20+2.debian.tar.gz
