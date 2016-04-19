#!/bin/sh

LEVEL_INFO=1
LEVEL_ERROR=2
LEVEL_FATAL=3

#Debug that level >= DEBUG_LEVEL will show on screen(console).
#e.g. : DEBUG_LEVEL=LEVEL_INFO, it indicates that all debug info will show on screen.
#e.g. : DEBUG_LEVEL=LEVEL_ERROR, it indicates that both LEVEL_ERROR and LEVEL_FATAL info will show on screen.
#e.g. : DEBUG_LEVEL=LEVEL_FATAL, it indicates that only LEVEL_FATAL info will show on screen.
DEBUG_LEVEL=LEVEL_INFO

#@in 1: level
#@in 2: info
#Desc : When call & pass $3 to this function, you must surround $3 with sign " otherwise $3 will be splited by blank space
function print_ln()
{
	level=$1
	info=$2
	
	printf "[%-15s] " $0 
	echo $info 
}

#@in 1: level
#@in 2: info
#Desc : When call & pass $2 to this function, you must surround $2 with sign " otherwise $2 will be splited by blank space
function print_head()
{
	level=$1
	info=$2
	
	printf "[%-15s] " $0 
	printf "$info" 
}

#@in 1: level
#@in 2: info
#Desc : When call & pass $2 to this function, you must surround $2 with sign " otherwise $2 will be splited by blank space
function print_body()
{
	level=$1
	info=$2

	printf "$info" 
}

#@in 1: level
function show_sh_begin_banner()
{
	level=1
	info="begin..."
	
	echo
	echo "--------------------------------------------------------------------------------"
	print_ln $level $info
}

#@in 1: level
function show_sh_end_banner()
{
	level=1
	info="end!!!"
	
	print_ln $level $info
	echo "................................................................................"
	echo
}