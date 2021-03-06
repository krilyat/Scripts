#!/bin/bash

export WINEPREFIX="/home/ben/WineMAO/"
export VST_PATH="${WINEPREFIX}/drive_c/vst/"
export WINE_RT=90
export WINE_SRV_RT=90

dtach="/usr/bin/dtach"
jackd="/usr/bin/jackd"

jack_dssi_host="/usr/bin/jack-dssi-host dssi-vst.so:"

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
jackdOptions="-P89 -dalsa -dhw:0 -r44000 -p92 -n2 -H -M -P"
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
    sleep 5
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

StartAll(){
StartJackd
sleep 2
StartVST Superior_Drummer_2.3.1
StartVST BREVERB_2
sleep 10
$dtach -n /tmp/klick_stock /usr/bin/gtklick
sleep 1
ConnectAll
}

ConnectAll(){
#disconnect ALL
for OUT in $(seq 1 2 32) ; do 
jack_disconnect "Superior Drummer 2 VST:Superior Drummer 2 VST out_$OUT" "system:playback_1" 
done
for OUT in $(seq 2 2 32) ; do 
jack_disconnect "Superior Drummer 2 VST:Superior Drummer 2 VST out_$OUT" "system:playback_2" 
done

#Connect ALL Superior Drummer
ALL=2
for OUT in $(seq 1 2 $ALL) ; do 
jack_connect "Superior Drummer 2 VST:Superior Drummer 2 VST out_$OUT" "BREVERB 2 VST:BREVERB 2 VST in_1" 
done
for OUT in $(seq 2 2 $ALL) ; do 
jack_connect "Superior Drummer 2 VST:Superior Drummer 2 VST out_$OUT" "BREVERB 2 VST:BREVERB 2 VST in_2" 
done

#Connect MIDI
aconnect  "MIDI 1 x 1:MIDI 1 x 1 MIDI 1" "Superior Drummer 2 VST:Superior Drummer 2 VST"
}

[ -z $1 ] && Usage;
while getopts sSv:V:kACl: OPT;do
case $OPT in
    s)	StartJackd;;
    S)  StopIt jackd;;
    v)	StartJackd
        StartVST $OPTARG;;
    V)  StopIt $OPTARG;;
    k)  StopIt jackd;;
    C)  ConnectAll;;
    A)  StartAll;;
    l)  sleep $OPTARG;;
    *)	Usage;;
esac
done
