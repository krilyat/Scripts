#!/bin/bash

#Import function
. $(dirname $0)/functions.sh

#set -x

Usage() {
cat << EOF
usage : $0 -[npPoc]
 options :
  -n : next governor
  -p : set powersave governor
  -P : set performance governor
  -o : set ondemand governor
  -c : set conservative governor
  -h : show this help
EOF
exit 1
}

SetGovernor() {
NEWGOV=$1
for PROC in $(cpufreq-info -o | grep ^CPU | awk '{print $2}') ;do
        sudo cpufreq-set -c $PROC -g $NEWGOV
done
}
[ -z $1 ] && Usage;
while getopts npPoch OPT; do
	case $OPT in
	p)SetGovernor powersave;;
	P)SetGovernor performance;;
	o)SetGovernor ondemand;;
	c)SetGovernor conservative;;
	n)GOV=$(cpufreq-info -o | grep ^CPU | awk '{print $14}' | uniq)
		case $GOV in
		"powersave")SetGovernor performance;;
		"ondemand")SetGovernor powersave;;
		"performance")SetGovernor ondemand;;
		esac;;
	*)Usage;;
	esac
done
CURGOV=$(cpufreq-info -o | grep ^CPU | awk '{print $14}' | uniq)

Popup -t "CPU" -m "$CURGOV"
