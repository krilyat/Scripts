#!/bin/bash
FILM=$1

if [ $(mkvinfo $FILM | grep -c header) -ne 0 ] ;then
	echo "remove compression header from $FILM"
	OLDFILM="${FILM::-4}.mkv_old"
	NEWFILM="${FILM::-4}_remux.mkv"
	echo "Strat processiong..."
	echo "mkvmerge -o $NEWFILM --engage keep_bitstream_ar_info -A -S --compression -1:none $FILM -D -S --compression -1:none $FILM -A -D --compression -1:none $FILM"
	mkvmerge -o $NEWFILM --engage keep_bitstream_ar_info -A -S --compression -1:none $FILM -D -S --compression -1:none $FILM -A -D --compression -1:none $FILM
	if [ $? -eq 0 ] ;then
		echo "Renommage de $FILM en $OLDFILM"
		mv $FILM $OLDFILM
		echo "Renommage de $NEWFILM en $FILM"
		mv $NEWFILM $FILM
	else
		echo "erreur lors de la supression de la compression"
		exit 1
	fi
else
	echo "No header compression ... nothing to do !"	
fi

exit 0
