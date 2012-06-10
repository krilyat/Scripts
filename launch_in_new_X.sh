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
X $DISPLAY &
readonly XPID=$!
}

LaunchWineApp(){
export $DISPLAY
export $WINEPREFIX
APPDIR=$(dirname $APP)
APPL=$(echo $APP | awk -F'/' '{print $NF}')

cd $APPDIR
wine $APPL
}

LaunchApp(){
export $DISPLAY

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

