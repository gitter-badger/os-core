# trigger display setup
tcos-xrandr # will write $HOME/.tcos_displayrc

# bring in tcos display settings variables
[ -f $HOME/.tcos_displayrc ] && . $HOME/.tcos_displayrc

# populate desktop icons
tcos-desktop-populate

# start X
exec mate-session
