#!/bin/bash
. $(dirname $0)/functions.sh
#set -x

MODULE="wl"
INTERFACE="wlan0"
WPA_CONF="/etc/wpa_supplicant.conf"
WPA_PID="/var/run/wpa_supplicant.pid"
DHCPCD_PID="/var/run/dhcpcd.pid"
WPA_SUPPLICANT=(wpa_supplicant -B -i $INTERFACE -c $WPA_CONF -P $WPA_PID)
#PASSWORD=$(zenity --password)
PASSWORD="totoprout"


function UnloadModule() {
echo $PASSWORD | sudo -S modprobe -r $MODULE
}

function LoadModule() {
echo $PASSWORD | sudo -S modprobe $MODULE
}

function ReleaseDHCP() {
if  [ -f $DHCPCD_PID ] ;then
	echo $PASSWORD | sudo -S dhcpcd --release $INTERFACE
fi
}

function SetDHCP() {
if  ! [ -f $DHCPCD_PID ] ;then
	echo $PASSWORD | sudo -S dhcpcd $INTERFACE
else
	ReleaseDHCP
	SetDHCP
fi
}

function StartWPA() {
echo $PASSWORD | sudo -S ${WPA_SUPPLICANT[@]}
}

function KillWPA() {
if [ -f $WPA_PID ] ;then
	echo $PASSWORD | sudo -S killall wpa_supplicant
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
	#ESSID=$(sudo iwconfig $INTERFACE | grep ESSID | cut -d '"' -f2)
	#${PRINT[@]} "Started on ESSID : $ESSID"
	(Popup -t "Wifi" -m "Started")
fi
}

Main
