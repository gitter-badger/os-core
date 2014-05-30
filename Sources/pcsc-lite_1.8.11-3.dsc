-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Format: 3.0 (quilt)
Source: pcsc-lite
Binary: pcscd, libpcsclite-dev, libpcsclite1-dbg, libpcsclite1
Architecture: any
Version: 1.8.11-3
Maintainer: Ludovic Rousseau <rousseau@debian.org>
Homepage: http://pcsclite.alioth.debian.org/
Standards-Version: 3.9.5
Vcs-Browser: http://anonscm.debian.org/viewvc/collab-maint/deb-maint/pcsc-lite/trunk/
Vcs-Svn: svn://anonscm.debian.org/collab-maint/deb-maint/pcsc-lite/trunk
Build-Depends: debhelper (>= 9), flex, dh-autoreconf, libudev-dev [linux-any], libusb2-dev [kfreebsd-any], pkg-config, dpkg-dev (>= 1.16.1~), dh-systemd (>= 1.4)
Package-List: 
 libpcsclite-dev deb libdevel optional arch=any
 libpcsclite1 deb libs optional arch=any
 libpcsclite1-dbg deb debug extra arch=any
 pcscd deb misc optional arch=any
Checksums-Sha1: 
 b72e506978121cde284f8b0b01986df74728dc7a 571837 pcsc-lite_1.8.11.orig.tar.bz2
 3ae2057bdb289521dda72fa059d2c855ed04d555 14380 pcsc-lite_1.8.11-3.debian.tar.xz
Checksums-Sha256: 
 945041c94c53959ae5a767616a4ec5099fe67f549bfd344e8bd0cfe7a3c71ac6 571837 pcsc-lite_1.8.11.orig.tar.bz2
 f549420daea8910a59867c0fc2f8a66db27a76ea24a1f38402a7e24c708e63ed 14380 pcsc-lite_1.8.11-3.debian.tar.xz
Files: 
 73502ca4ba6526727f9f49c63d805408 571837 pcsc-lite_1.8.11.orig.tar.bz2
 d6b9f6c4d1c4560174d6be9c369eb9c0 14380 pcsc-lite_1.8.11-3.debian.tar.xz

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJTeNLpAAoJEHihtN/o+cV+yLgP/22WZmEamIqxtU2ZsVnqRpZ8
m+et3xiGO01pBNjj2SCA2quLwnkq+DCa5248lFjV/nh85Aq7sItU3I+fDO+1iXfh
gYS0MiJ/Wxt72GmnCN84iL8nsQm0FbDbLlX5MCB/rSlBc6pzgKpBpMX1Np8sx6HJ
EzF7aAl60Zr5PMt5F+G5sxo/4xeitMeMWfZCAMxV6mZXaT7KJl9gckpZcEZwkqwm
364SRmWkr90cHYGUExkFj5b+WuS3pfoMfl5KbqsiQ99/X4ZzodCc/ns40mP7UsgS
B934FQN3gY/dV0lnwSwMtGdooX/EIuFulAbCp+ymh3/avxx9loAt/+Wy+UsE733a
vb3hHroArm+FXOA4+GHt3/6sZxl6nYW1tdXniFwm535e9u+abv8yULutfddIlWt0
hh91ns54JA3WCqYBIn5OFnYkt0BGMzUnubMeqH+4qcDyKmDFypkS0QQNdB7b3MBh
61upz1QRtB5C2xBGIeQ9TbOXAURxidyInCO83FYIHaKhnUov1TLfajHnUyNC5SUF
sm9r69YxfX5vDOzIcjgWDCZ55DCNoy6V8gSy9cuRWn72o6DepVUAZS4BySIjD9oM
fjxwp7Ym1Q9OqpiUD5rwMHt5Amo0r/m0wEW+eLoCHvJlNhSMe/wWkVrYfTGTzvTi
Z7hx8YCyEtqprSiK1hvT
=YX8W
-----END PGP SIGNATURE-----
