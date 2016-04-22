#!/bin/sh

#@in  1: drive name
#@out 2: return content by parted /dev/xxx p
function get_disk_size_string() ###???
{
	drive_name=$1
	
	eval $2=`parted /dev/$drive_name p`
	
	return 1
}

#@in  1: drive size file (e.g.: )
#@out 2: drive size		 (e.g.: )
#@out 3: drive size unit (e.g.: GB/MB)
#return: 1:true/0:false
function parse_disk_size_file()
{
	size_string_file=$1
	
	eval $2=`cat $size_string_file | grep ^Disk | awk '{print int($3)}'`
	eval $3="GB"
	
	return 1
}

#@in  1: drive name 	 (e.g.: sda/sdb/hda/hdb)
#@out 2: drive size		 (e.g.: )
#@out 3: drive size unit (e.g.: GB/MB)
#return: 1:true/0:false
function get_disk_size()
{
	drive_name=$1
	
	eval $2=`parted /dev/$drive_name p | grep ^Disk | awk '{print int($3)}'`
	eval $3="GB"
	
	return 1 
}

#@out 1: drive size		 (e.g.: )
#@out 2: drive size unit (e.g.: GB/MB)
#return: 1:true/0:false
function get_memory_size()
{
	eval $1=`dmidecode | grep -P -A5 "Memory\s+Device" | grep Size | grep -v Range | head -n 1 | awk '{print $2}'`
	eval $2=`dmidecode | grep -P -A5 "Memory\s+Device" | grep Size | grep -v Range | head -n 1 | awk '{print $3}'`
	
	return 1 
}