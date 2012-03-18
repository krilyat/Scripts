#!/bin/bash
#
#Renommer une arborescence en remplacent les espaces par '_' 
#
#utiliser la commande find . -depth -name '* *' --exec [script] {} \;
IFSBACK=$IFS
IFS="`echo -ne "\n"`"
cd $(dirname $1)
NAME=$(echo $1 | awk -F'/' '{print $NF}')
mv "$NAME" "`echo $NAME | tr ' ' '_'`"
IFS=$IFSBACK
