# trigger display setup
tcos-xrandr # will write $HOME/.tcos_displayrc

# bring in tcos display settings variables
. $HOME/.tcos_displayrc

# populate desktop icons
tcos-desktop-populate

# start X
exec mate-session

