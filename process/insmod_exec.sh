#!/bin/sh

source system.sh
source file.sh

MODULES_DIRX=$1

INFO=$LEVEL_INFO
ERROR=$LEVEL_ERROR
FATAL=$LEVEL_FATAL

# in 1: level
# in 2: info
# Desc:
function debugx()
{
	debug "$0" "$1" "$2"
}

function parse_insmod_conf()
{
	echo
}

show_sh_begin_banner $0

debugx $FATAL test

for dir in $MODULES_DIRX/*
do
    if [ -d $dir ];then
		debugx $INFO "Enter into folder $dir"
		cd $dir
		ls -l
		
		is_file_exist insmod.conf result
		echo insmod.conf-result=$result
		
		is_file_exist insmod.sh result
		echo insmod.sh-result=$result
		
		cd ..
	fi
done


show_sh_end_banner $0