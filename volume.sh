#!/bin/bash
#set -x
#. $(dirname $0)/functions.sh
UPDATEFILE="/home/bob/.config/wmfs/volume"

function PrintVolume() {
PVOL=$(amixer get "Master" | grep -E '\[.*\]' | tr -d '\[\|\]\|%' | awk '{print $(NF-2)}')
DBVOL=$(amixer get "Master" | grep -E '\[.*\]' | awk '{print $(NF-1)}')
ONOFF=$(amixer get "Master" | grep -E '\[.*\]' | awk '{print $(NF)}')

if [ X$ONOFF == "X[on]" ] ;then
	#${PRINT[@]} "$PVOL"
	echo "$PVOL" > $UPDATEFILE
	Popup -t "Volume" -m "$PVOL%"
else
	#${PRINT[@]} "Mute"
	echo "0" > $UPDATEFILE
	Popup -t "Volume" -m "Mute"
fi
}

case $1 in
"--") if [ "$PVOL" != "0%" ] ;then
		[ $UID -eq "0" ] && su - bob -c 'amixer -q sset "Master,0" 2-' || amixer -q sset "Master,0" 2-
	else
		exit 0
	fi;;
"++") if [ "$PVOL" != "100%" ] ;then
		[ $UID -eq "0" ] && su - bob -c 'amixer -q sset "Master,0" 2+' || amixer -q sset "Master,0" 2+
	else
		exit 0
	fi;;
"x")[ $UID -eq "0" ] && su - bob -c 'amixer -q sset "Master,0" toggle' || amixer -q sset "Master,0" toggle
;;
esac

#PrintVolume
