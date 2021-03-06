#!/bin/bash
FILM=$1

if [ $(mkvinfo $FILM | grep -c header) -ne 0 ] ;then
	OLDFILM="${FILM::${#FILM}-4}.mkv"
	NEWFILM="${FILM::${#FILM}-4}_remux.mkv"
    if [ -f $NEWFILM ] ;then
        echo "nothing to do"
        exit 42
    fi 
	echo "remove compression header from $FILM"
	echo "Strat processiong..."
	echo "mkvmerge -o $NEWFILM --engage keep_bitstream_ar_info -A -S --compression -1:none $FILM -D -S --compression -1:none $FILM -A -D --compression -1:none $FILM"
	#mkvmerge -o $NEWFILM --engage keep_bitstream_ar_info -A -S --compression -1:none $FILM -D -S --compression -1:none $FILM -A -D --compression -1:none $FILM
    mkvmerge -o $NEWFILM -A -S --compression -1:none $FILM -D -S --compression -1:none $FILM -A -D --compression -1:none $FILM
	if [ $? -eq 0 ] ;then
		#echo "Renommage de $FILM en $OLDFILM"
		#mv $FILM $OLDFILM
		#echo "Renommage de $NEWFILM en $FILM"
		#mv $NEWFILM $FILM
        echo "remux OK"
	else
		echo "erreur lors de la supression de la compression"
		exit 1
	fi
else
	echo "No header compression ... nothing to do !"	
fi

exit 0
