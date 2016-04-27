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

#@in  1: Drive name		(e.g.: sda/sdb/hda/hdb)
#@out 2: Partition count
function get_disk_partition_count()
{
	drive_name=$1
	partition_count="null"
	
	partition_count=`parted /dev/$drive_name p | awk '!/^$/' | awk 'n==1{print}$0~/Number/{n=1}' | wc -l`

	eval $2=$partition_count
	
	return 1
}

#@in  1: Cmd that can output partition info (e.g.: "parted /dev/sda p")
#@out 2: Partition count
function parse_disk_partition_count_from_cmd()
{
	cmd=$1
	partition_count="null"
	
	partition_count=`$cmd | awk '!/^$/' | awk 'n==1{print}$0~/Number/{n=1}' | wc -l`

	eval $2=$partition_count
	
	return 1
}

#@in  1: Drive name		(e.g.: sda/sdb/hda/hdb)
#@in  2: Partition index
#@out 3: End size
function get_disk_partition_end_size()
{
	drive_name=$1
	partition_index=$2
	end_size="null"
	#set -x
	end_size=`parted /dev/$drive_name p | awk '!/^$/' | awk 'n==1{print}$0~/Number/{n=1}' | awk '{print $3}' | awk "NR==$partition_index"`
	#set +x
	eval $3=$end_size
	
	return 1
}

#@in  1: Cmd that can output partition info (e.g.: "parted /dev/sda p")
#@in  2: Partition index
#@out 3: End size
function parse_disk_partition_end_size_from_cmd()
{
	cmd=$1
	partition_index=$2
	end_size="null"
	#set -x
	end_size=`$cmd | awk '!/^$/' | awk 'n==1{print}$0~/Number/{n=1}' | awk '{print $3}' | awk "NR==$partition_index"`
	#set +x
	eval $3=$end_size
	
	return 1
}