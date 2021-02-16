#!/bin/sh

function run {
  if ! pgrep $1 ;
  then 
    $@&
  fi
}


xinput set-prop "AlpsPS/2 ALPS DualPoint TouchPad" "libinput Tapping Enabled" 1

################################
# Programms
################################
keyboardInit
# transparency
run picom -b --experimental-backends --config ~/.config/awesome/configuration/picom.conf
# run picom  --config ~/.config/picom/picom.conf --experimental-backends
# automounting usb drives
run udiskie 
# mouse disappears
run unclutter 
# for quicker emacs
# run emacs --bg-daemon 
# for nightmode
run redshift 
run nextcloud

################################
# Applets
################################
run flameshot
run blueman-applet
run nitrogen --restore 
