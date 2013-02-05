#!/bin/bash


export WINEPREFIX="/home/ben/WineMAO/"
export VST_PATH="${WINEPREFIX}/drive_c/vst/"
export WINE_RT=90
export WINE_SRV_RT=90

dtach="/usr/bin/dtach"
tmpdir="/tmp"

jackd="/usr/bin/jackd"
jackdpid="${tmpdir}/jackd_pid"
jackdsocket="${tmpdir}/jackd_dtc"

vstpid="${tmpdir}/vst_pid"
vstsocket="${tmpdir}/vst_dtc"
vsthost="/usr/bin/vsthost"

jp1="/usr/bin/jp1"
gtklick="/usr/bin/gtklick"

Usage() {
cat << EOF

Usage : $0 -[skg] <-V VST>
 Options :
  -s : Launch Jackd
  -k : stop Jackd
  -V 'VST'	: Launch Jackd  and a vst plugin (name without '.dll)
EOF
exit 1
}

StartJackd() {
jackdOptions="\
-P89 \
-dalsa \
-dhw:0 \
-r48000 \
-p75 \
-n2 \
-S \
-H \
-M"

if ! [ -S $jackdsocket ] ;then
	$dtach -n $jackdsocket -e ^d $jackd ${jackdOptions[@]}
    echo $$ > $jackdpid
fi
}

StartVST() {
if ! [ -S $vstsocket ] ;then
	$dtach -n $vstsocket -e ^d $vsthost ${VST}.dll
    echo $$ > $vstpid
fi
}

StopJackd() {
if [ -S $jackdsocket ] ;then
	kill $(cat $jackdpid)
fi
}

StopVSTs() {
if [ -S $vstsocket ] ;then
	kill $(cat $vstpid)
fi
}

LaunchPatchbay() {

$jp1
$gtklick

}

[ -z $1 ] && Usage;
while getopts skgV: OPT;do
case $OPT in
    s)	StartJackd;;
    k)	StopVSTs
        StopJackd;;
    V)	VST="Superior_Drummer"
        StartJackd
        sleep 2
        StartVST
        LaunchProgram;;
    *)	Usage;;
esac
done
