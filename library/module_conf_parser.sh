#!/bin/sh

#ks:mode:destination:source_file
#initrd:...unfinished
#iso:...unfinished

source debug.sh


KS_FORMAT="ks:mode:destination:source_file"

#@in  1: one line of insmod.conf
#@out 2: object
function get_ojcect_from_conf_line
{
	line=$1
	
	object=`echo $line | awk -F ":" '{print $1}'`
	
	eval $2=$object
	return 1
}

#@in  1: one line of insmod.conf
#@out 2: mode
#@out 3: destination
#@out 4: source file
function get_ks_params
{
	line=$1
	
	object=`echo $line | awk -F ":" '{print $1}'`
	mode=`echo $line | awk -F ":" '{print $2}'`
	destination=`echo $line | awk -F ":" '{print $3}'`
	source_file=`echo $line | awk -F ":" '{print $4}'`
	
	eval $2=$mode
	eval $3=$destination
	eval $4=$source_file
	return 1
}
