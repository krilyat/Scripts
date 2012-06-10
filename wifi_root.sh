#!/bin/bash
. $(dirname $0)/functions.sh
set -x
export DISPLAY=:0.0

MODULE="wl"
INTERFACE="wlan0"
WPA_CONF="/etc/wpa_supplicant.conf"
WPA_PID="/var/run/wpa_supplicant.pid"
DHCPCD_PID="/var/run/dhcpcd.pid"
WPA_SUPPLICANT=(wpa_supplicant -B -i $INTERFACE -c $WPA_CONF -P $WPA_PID)


function UnloadModule() {
modprobe -r $MODULE
}

function LoadModule() {
modprobe $MODULE
}

function ReleaseDHCP() {
if  [ -f $DHCPCD_PID ] ;then
	dhcpcd --release $INTERFACE
fi
}

function SetDHCP() {
if  ! [ -f $DHCPCD_PID ] ;then
	dhcpcd $INTERFACE
else
	ReleaseDHCP
	SetDHCP
fi
}

function StartWPA() {
${WPA_SUPPLICANT[@]}
}

function KillWPA() {
if [ -f $WPA_PID ] ;then
	killall wpa_supplicant
fi
}

function Main() {
if [ -f $WPA_PID ] ;then
	(Popup -t "Wifi" -m 'Shutting Down')
	ReleaseDHCP
	KillWPA
	UnloadModule
	(Popup -t "Wifi" -m "Shut Down Complete")
else
	(Popup -t "Wifi" -m "Starting Up")
	LoadModule
	sleep .4
	StartWPA
	SetDHCP
	sleep 1
	(Popup -t "Wifi" -m "Started")
fi
}

Main
