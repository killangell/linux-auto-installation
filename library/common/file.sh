#!/bin/sh

#@in  1: file_path
#return: result(true/false)
function is_file_exist()
{
	file_path=$1
	
	if [ ! -f $file_path ];then
		return 0
	else
		return 1
	fi
}

#@in  1: file_path
#return: result(true/false)
#Desc  : Starting with "^#" line and "blank" line are useless
function is_useless_line()
{
	if [[ $line = *#* ]];then
		return 1
	elif [[ $line = "" ]];then
		return 1
	elif [[ $line = "\n" ]];then
		return 1
	fi
	
	return 0
}

#@in  1: file_path
#@out 1: count
#Desc  : exclude "^#" line and "blank" line
#function get_file_useful_line_count()


