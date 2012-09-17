#!/bin/bash

DISPLAY=:1
USEWINE=0
WINEPREFIX=""
XPID=""

while getopts wp:a: OPT ;do
	case $OPT in
		w) readonly USEWINE=1;;
		p) readonly WINEPREFIX=$OPTARG ;;
		a) readonly APP=$OPTARG ;;
	esac
done

InitDisplay(){
export DISPLAY=$DISPLAY
X $DISPLAY &
sleep 1
xcalib ~/.config/nf310.icc > /dev/null 2>&1
readonly XPID=$!
}

LaunchWineApp(){
export WINEPREFIX=$WINEPREFIX
APPDIR=$(dirname $APP)
APPL=$(echo $APP | awk -F'/' '{print $NF}')

cd $APPDIR
wine $APPL
}

LaunchApp(){
$APP
}

StopDisplay(){
kill $XPID
}

InitDisplay
if [ $USEWINE -eq 1 ] ;then
	LaunchWineApp
else
	LaunchApp
fi
StopDisplay

