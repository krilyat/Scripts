#!/bin/bash

. $(dirname $0)/functions.sh
CPU="$(dirname $0)/CPU-set.sh"

Usage() {
cat << EOF

Usage : $0 -[skg] <-V VST>
 Options :
  -s : Launch Jackd and Qjackctl
  -k : stop Jackd and Qjackctl
  -g : Launch Qjackctl alone
  -V 'VST'	: Launch Jackd Qjackctl AND a vst plugin (name without '.dll)
EOF
exit 1
}

Qjackctl() {
if ! [ -S /tmp/qjackctl_dtc ] ;then
	dtach -n /tmp/qjackctl_dtc -e ^d /usr/bin/qjackctl
fi
}

StartJackd() {
if ! [ -S /tmp/jackd_dtc ] ;then
	$CPU "performance"
	#dtach -n /tmp/jackd_dtc -e ^d /usr/bin/jackd -P89 -p256 -t500 -dalsa -dhw:0 -r88200 -p128 -n2
	#dtach -n /tmp/jackd_dtc -e ^d /usr/bin/jackd -P89 -p128 -t200 -dalsa -dhw:0 -r48000 -p128 -n1
	#dtach -n /tmp/jackd_dtc -e ^d /usr/bin/jackd -P89 -p128 -t200 -dalsa -dhw:0 -r48000 -p96 -n1
	dtach -n /tmp/jackd_dtc -e ^d /usr/bin/jackd -P89 -p128 -t200 -dalsa -dhw:1 -r48000 -p96 -n1
	sleep 1
	(Popup -t "Jackd" -m "Started")
else
	(Popup -t "Jackd" -m "Already Started")
fi
}

StopJackd() {
if [ -S /tmp/jackd_dtc ] ;then
	pkill jackd
	(Popup -t "Jackd" -m "Stoped")
	$CPU "ondemand"
fi
sleep 1
if [ -S /tmp/qjackctl_dtc ] ;then
	pkill qjackctl
fi
}

StartVST() {
VST="$1"
if ! [ -S /tmp/vsthost_${VST}_dtc ] ;then
	export WINEPREFIX=/home/bob/.wine 
	export VST_PATH='/home/bob/.wine/drive_c/VSTPlugIns/' 
	export WINE_RT=15 
	export WINE_SRV_RT=10
	dtach -n /tmp/vsthost_${VST}_dtc -e ^d /usr/bin/vsthost ${VST}.dll
	(Popup -t "${VST}" -m "Starting...")
fi
}

StopVSTs() {
if [ -S /tmp/vsthost_*_dtc ] ;then
	pkill vsthost
	(Popup -t "VSTplugin" -m "Stoped")
fi
}

[ -z $1 ] && Usage;
while getopts skgV: OPT;do
case $OPT in
s)	StartJackd
	Qjackctl;;
k)	StopVSTs
	StopJackd;;
g)	Qjackctl;;
V)	StartJackd
	Qjackctl
	StartVST ${OPTARG};;
*)	Usage;;
esac
done
