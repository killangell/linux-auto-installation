#!/bin/sh

:<<system_block
CURRENT_PATH=`pwd`
SYSTEM_DIR=$CURRENT_PATH/system
LIBRARY_DIR=$CURRENT_PATH/library
LIBRARY_DIR_COMMON=$CURRENT_PATH/library/common
PROCESS_DIR=$CURRENT_PATH/process
MODULES_DIR=$CURRENT_PATH/modules
system_block


LEVEL_INFO=1
LEVEL_ERROR=2
LEVEL_FATAL=3

# in 1: shell script name
# in 2: level
# in 3: info
# Desc:
function debug()
{
	sh_name=$1
	level=$2
	info=$3
	
	#echo total=$@
	#echo num=$#
	#echo $sh_name, $level, "$info"
	
	printf "[%-15s] " $sh_name 
	echo $info # Must surround $3 with sign " otherwise $3 will be splited by blank space
}

# in 1: shell script name
# in 2: level
# in 3: info
# Desc:
function print_proc()
{
	sh_name=$1
	level=$2
	info=$3
	
	printf "[%-15s] " $sh_name 
	printf "$info" 
}

# in 1: level
# in 2: info
# Desc:
function print()
{
	info=$2

	printf "$info" 
}

function show_sh_begin_banner()
{
	sh_name=$1
	level=1
	info="begin..."
	
	echo
	#echo "################################################################################"
	echo "--------------------------------------------------------------------------------"
	print_ln $sh_name $level $info
}

function show_sh_end_banner()
{
	sh_name=$1
	level=1
	info="end!!!"
	
	print_ln $sh_name $level $info
	#echo "################################################################################"
	#echo "--------------------------------------------------------------------------------"
	echo "................................................................................"
	echo
}