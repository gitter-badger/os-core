Format: 3.0 (quilt)
Source: pcsc-lite
Binary: pcscd, libpcsclite-dev, libpcsclite1-dbg, libpcsclite1
Architecture: any
Version: 1.8.11-3~tcos20+4
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
 67498fec93c9e72781df811fa537949f0529c0a1 15928 pcsc-lite_1.8.11-3~tcos20+4.debian.tar.gz
Checksums-Sha256: 
 945041c94c53959ae5a767616a4ec5099fe67f549bfd344e8bd0cfe7a3c71ac6 571837 pcsc-lite_1.8.11.orig.tar.bz2
 18c1af44085e30fc65726913c17d7317de6440ffad586ef36fe0c0dd30fd6343 15928 pcsc-lite_1.8.11-3~tcos20+4.debian.tar.gz
Files: 
 73502ca4ba6526727f9f49c63d805408 571837 pcsc-lite_1.8.11.orig.tar.bz2
 5941a38afd8e14ece3511b8a6584f0e5 15928 pcsc-lite_1.8.11-3~tcos20+4.debian.tar.gz
