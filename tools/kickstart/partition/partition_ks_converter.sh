#!/bin/sh

source partition_define.sh
source disk.sh

#@in  1: Partition name
#@in  2: Partition size	
#@in  3: Partition filesystem	
#@out 4: Output pattition string 
function get_ks_disk_partition_string()
{
	name=$1
	size=$2
	fs_type=$3
	mount_point="null"
	output_string="null"
	
	get_partition_mount_point_by_name $name mount_point
	
	if [ $size != "max" ];then
		if [ $name = "swap" ];then
			output_string="part $mount_point --asprimary --size=$size"
		else
			output_string="part $mount_point --fstype=$fs_type --asprimary --size=$size"
		fi
	else
		output_string="part $mount_point --fstype=$fs_type --asprimary --grow --size=1"
	fi	 
	
	#echo output_string="$output_string"
	#Because eval limits, replace blank space to plus 
	eval $4=$(echo $output_string | sed 's/ /+/g')
	return 1
}

#@in  1: Partition name 		(eg. boot)
#@in  2: Partition size	
#@in  3: Partition filesystem	
#@in  4: Volume group
#@out 5: Output partition string
function get_ks_lvm_partition_string()
{
	name=$1
	lv_name=lv_$1
	size=$2
	fs_type=$3
	vgname=$4
	mount_point="null"
	output_string="null"
	
	get_partition_mount_point_by_name $name mount_point
	
	if [ $size != "max" ];then
		if [ $name = "swap" ];then
			output_string="logvol $mount_point --vgname=$vgname --size=$size --name=$lv_name"
		else
			output_string="logvol $mount_point --fstype=$fs_type --vgname=$vgname --size=$size --name=$lv_name"
		fi
	else
		output_string="logvol $mount_point --fstype=$fs_type --vgname=$vgname --size=1 --grow --name=$lv_name"
	fi	 
	
	#Because eval limits, replace blank space to plus 
	#echo output_string=$output_string
	eval $5=$(echo $output_string | sed 's/ /+/g')
	return 1
}

#@in  1: Partition name that iso located. (e.g.: it may be sda2/sda3..)
#@out 2: Output pattition string 
function get_ks_harddrive_string()
{
	#iso_loca=$dest_drive$prel_iso_partition_num
	iso_loca=$1
	output_string="null"
	
	output_string="harddrive --partition=$iso_loca --dir="
	
	#Because eval limits, replace blank space to plus 
	eval $2=$(echo $output_string | sed 's/ /+/g')
	
	return 1
}

#@in  1: Dest drive to install os (e.g.: sda/hda)
#@out 2: Output pattition string 
function get_ks_bootloader_string()
{
	dest_drive=$1
	output_string="null"
	
	output_string="bootloader --location=mbr --driveorder=$dest_drive --append=\\\"crashkernel=auto rhgb quiet\\\""
	#Because eval limits, replace blank space to plus
	#set -x 
	#echo output_string1=$output_string
	eval $2=$(echo $output_string | sed 's/ /+/g')
	#echo output_string2=$2
	#set +x
	
	return 1
}

