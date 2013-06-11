#!/bin/bash
set -x
export WINEPREFIX="/home/ben/WineMAO/"
export VST_PATH="${WINEPREFIX}/drive_c/vst/"
export WINE_RT=90
export WINE_SRV_RT=90

dtach="/usr/bin/dtach"
jackd="/usr/bin/jackd"
vsthost="/usr/bin/vsthost"
jack_dssi_host="/usr/bin/jack-dssi-host dssi-vst.so:"
jp1="/usr/bin/jp1"
gtklick="/usr/bin/gtklick"

tmpdir="/tmp"

Usage() {
cat << EOF

Usage : $0 -[skg] <-V VST>
 Options :
  -s : Launch Jackd
  -S : Stop Jackd
  -k : stop everything
  -v 'VST'	: Launch Jackd  and a vst plugin (name without '.dll)
  -V 'VST'	: Stop 'VST'
EOF
exit 1
}

StartJackd() {
jackdOptions="-P89 -dalsa -dhw:1 -r44000 -p128 -n2 -H -M"
_socket="${tmpdir}/jackd_sock"
_pid="${tmpdir}/jackd_pid"

if ! [ -S $_socket ] ;then
	$dtach -n $_socket $jackd ${jackdOptions[@]}
    ps aux | grep "$dtach -n $_socket $jackd ${jackdOptions[@]}" | grep -v grep | awk '{print $2}' > $_pid
    sleep 2
fi
}

StartVST() {
set -x
[ -z $1 ] && Usage;
_vst=$1
_socket="${tmpdir}/${_vst}_sock"
_pid="${tmpdir}/${_vst}_pid"

if ! [ -S $_socket ] ;then
	$dtach -n $_socket ${jack_dssi_host}${_vst}.dll
    ps aux | grep "$dtach -n $_socket ${jack_dssi_host}${_vst}.dll" | grep -v grep | awk '{print $2}' > $_pid
    sleep 1
fi
}

StopIt() {
[ -z $1 ] && Usage;
_base="${tmpdir}/${1}"
_socket="${_base}_sock"
_pid="${_base}_pid"

if [ -S $_socket ] ;then
	kill $(cat $_pid)
    rm -f $_pid
fi
if [ $_socket == "/tmp/jackd_sock" ] ;then
    killall $jackd
fi
}

[ -z $1 ] && Usage;
while getopts sSv:V:k OPT;do
case $OPT in
    s)	StartJackd;;
    S)  StopIt jackd;;
    v)	StartJackd
        StartVST $OPTARG;;
    V)  StopIt $OPTARG;;
    k)  StopIt jackd
        ;;
    *)	Usage;;
esac
done
