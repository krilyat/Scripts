#!/bin/bash
export DISPLAY=:0.0
#su - bob -c "/home/bob/script/update_awesome_widget"

COMMAND="/sbin/poweroff"
SCHARGE=$1
NCHARGE="15"
PRINT=(notify-send Battery: )

if [ $(cat /sys/class/power_supply/ADP1/online) -eq 0 ] ; then
    CNOW=$(cat /sys/class/power_supply/BAT1/charge_now)
    CFULL=$(cat /sys/class/power_supply/BAT1/charge_full)

    CHARGE=$(($CNOW*100/CFULL))

    if [ $CHARGE -le $SCHARGE ] ;then
        $COMMAND
    fi
    if [ $CHARGE -le $NCHARGE ] ;then
        ${PRINT[@]} "$CHARGE%"
    fi

fi
