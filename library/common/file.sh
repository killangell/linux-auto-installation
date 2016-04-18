#!/bin/sh

#@in  1: file_path
#@out 2: result(true/false)
function is_file_exist()
{
	file_path=$1
	result=$2
	
	if [ ! -f $file_path ];then
		eval $2=false
	else
		eval $2=true
	fi
}

#@in  1: file_path
#@out 2: result(true/false)
function is_file_exist2()
{
	file_path=$1
	
	if [ ! -f $file_path ];then
		return 0
	else
		return 1
	fi
}

#@in  1: file_path
#@out 1: count
#Desc  : include "^#" line and "blank" line
#function get_file_all_line_count()

#@in  1: file_path
#@out 1: count
#Desc  : exclude "^#" line and "blank" line
#function get_file_useful_line_count()


