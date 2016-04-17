#!/bin/sh

source system.sh

MODULES_DIRX=$1

INFO=$LEVEL_INFO
ERROR=$LEVEL_ERROR
FATAL=$LEVEL_FATAL

# in 1: level
# in 2: info
# Desc:
function debugx()
{
	debug $0 $1 $2
}

show_sh_begin_banner $0

debugx $FATAL test

echo $MODULES_DIRX
all=`ls $MODULES_DIRX`
#for dir in $(ls $MODULES_DIRX)
for dir in $all
do
    [ -d $dir ] && echo $dir
done


show_sh_end_banner $0