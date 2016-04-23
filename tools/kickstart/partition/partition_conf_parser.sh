#!/bin/sh

source file.sh

#@in  1: partition conf
#@out 2: dest drive
function get_conf_dest_drive()
{
	conf_file=$1
	dest_drive="null"
	
	while read line
	do	
		is_useless_line $line
		if [ $? -eq 1 ];then
			continue
		fi
		
		if [[ $line = *=* ]];then
			left_value=`echo $line | awk -F "=" '{print $1}'`
			right_value=`echo $line | awk -F "=" '{print $2}'`
			if [[ $left_value = *dest_drive* ]];then
				dest_drive=$right_value
				break
			fi
		fi	
	done < $conf_file
	
	eval $2=$dest_drive	
	return 1
}

#@in  1: partition conf
#@in  2: partition name
#@out 3: partition size
#@out 4: partition locate
#@out 5: partition filesystem type
function get_conf_partition_info_by_name()
{
	conf_file=$1
	name=$2
	size="null"
	loca="null"
	fs_type="null"
	
	while read line
	do	
		is_useless_line $line
		if [ $? -eq 1 ];then
			continue
		fi
		
		if [[ $line = *:* ]];then
			pt_name=`echo $line | awk -F ":" '{print $1}'`
			pt_size=`echo $line | awk -F ":" '{print $2}'`
			pt_loca=`echo $line | awk -F ":" '{print $3}'`
			pt_fs_type=`echo $line | awk -F ":" '{print $4}'`
			#echo " ptxx",$pt_name,$name,$pt_size,$pt_loca,$pt_fs_type
			if [[ $pt_name = *$name* ]];then
				size=$pt_size
				loca=$pt_loca
				fs_type=$pt_fs_type
				break
			fi
		fi	
	done < $conf_file
	
	eval $3=$size
	eval $4=$loca
	eval $5=$fs_type
	
	return 1
}