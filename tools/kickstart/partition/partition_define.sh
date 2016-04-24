#!/bin/sh

db_dest_drive=sda #Default value. OS will be intstalled on it.
pt_name_arr=( 
    efi				#0 /boot/efi
    boot			#1 /boot
	swap 			#2 /swap 
	root			#3 /root
	var				#4 /var 
	home			#5 /home
	tmp				#6 /tmp
	opt				#7 /opt
	usr				#8 /usr
			
	data			#9  /data   reserved
	#data			#10 /data   reserved
	#data			#11 /data   reserved
	#data			#12 /data   reserved
			
	#resv			#9
)
pt_size_arr=( #Default partition size 
    200M 			#0 /boot/efi
    200M 			#1 /boot
	?    			#2 /swap It depends on real memory size. 2*MemorySize
	10G  			#3 /root
	max  			#4 /var  The biggest partition
	20G  			#5 /home
	20G  			#6 /tmp
	20G  			#7 /opt
	20G  			#8 /usr
	
	0				#9  /data   reserved
	#0				#10 /data   reserved
	#0				#11 /data   reserved
	#0				#12 /data   reserved
	
	#6G  			#9 For preload files
)
pt_locate_arr=( #Default partition size 
    disk 			#0 /boot/efi  
    disk 			#1 /boot
	lvm    			#2 /swap It depends on real memory size. 2*MemorySize
	lvm  			#3 /root
	lvm  			#4 /var  The biggest partition
	lvm  			#5 /home
	lvm  			#6 /tmp
	lvm  			#7 /opt
	lvm  			#8 /usr
	
	lvm				#9  /data   reserved
	#lvm				#10 /data   reserved
	#lvm				#11 /data   reserved
	#lvm				#12 /data   reserved
	
	#lvm  			#9 For preload files
)
pt_fs_arr=( #Default partition size 
    vfat 			#0 /boot/efi  
    ext4 			#1 /boot
	ext4    		#2 /swap It depends on real memory size. 2*MemorySize
	ext4  			#3 /root
	ext4  			#4 /var  The biggest partition
	ext4  			#5 /home
	ext4  			#6 /tmp
	ext4  			#7 /opt
	ext4  			#8 /usr
	
	ext4			#9  /data   reserved
	ext4			#10 /data   reserved
	ext4			#11 /data   reserved
	ext4			#12 /data   reserved
	
	#lvm  			#9 For preload files
)

#@in  $1: partition name
#@out $2: partition mount point
function get_partition_mount_point_by_name()
{
	pt_name=$1
	partition="null"
	
	if [[ $pt_name = *swap* ]];then
		partition="swap"
	elif  [[ $pt_name = *efi* ]];then
		partition="/boot/efi"
	elif  [[ $pt_name = *boot* ]];then
		partition="/boot"
	elif  [[ $pt_name = *root* ]];then
		partition="/"
	elif  [[ $pt_name = *var* ]];then
		partition="/var"
	elif  [[ $pt_name = *home* ]];then
		partition="/home"
	elif  [[ $pt_name = *tmp* ]];then
		partition="/tmp"
	elif  [[ $pt_name = *opt* ]];then
		partition="/opt"
	elif  [[ $pt_name = *usr* ]];then
		partition="/usr"
	elif  [[ $pt_name = *data* ]];then
		partition="/data"
	fi
	
	eval $2=$partition
	
	return 1
}

#@out 1: dest drive
function get_dest_drive()
{
	eval $1=$db_dest_drive	
	return 1
}

#@in  1: dest drive
function set_dest_drive()
{
	db_dest_drive=$1
	return 1
}

#@in  1: partition name
#@out 2: partition index
function get_pt_name_index()
{
	index=100 
	partition_name_iterator=0	
	
	for item in ${pt_name_arr[*]}  
	do  
		if  [[ ${item} = *$1* ]];then
			index=$partition_name_iterator
			break
		fi
		let partition_name_iterator=$partition_name_iterator+1
	done 
	
	eval $2=$index
	return 1
}

#@in  1: index [0-9]
function is_valid_partition_index()
{
	index=$1
	
	if [ $index -lt 0 ];then
		return 0
	elif [ $index -gt 9 ];then
		return 0
	fi
	
	return 1
}

#@in  1: partition index
#@out 2: partition name
#@out 3: partition size
#@out 4: partition locate
#@out 5: partition filesystem type
function get_partition_info_by_index()
{
	index=$1
	name="null"
	size="null"
	loca="null"
	fs_type="null"
	
	is_valid_partition_index $index
	if [ $? != 1 ];then
		return 0
	fi
	
	name=${pt_name_arr[$index]}
	size=${pt_size_arr[$index]}
	loca=${pt_locate_arr[$index]}
	fs_type=${pt_fs_arr[$index]}
	
	eval $2=$name
	eval $3=$size
	eval $4=$loca
	eval $5=$fs_type
	
	return 1
}

#@in  1: partition index
#@in  2: partition name
#@in  3: partition size
#@in  4: partition locate
#@in  5: partition filesystem type
function set_partition_info_by_index()
{
	index="$1"
	name="$2"
	size="$3"
	loca="$4"
	fs_type="$5"
	
	is_valid_partition_index $index
	if [ $? != 1 ];then
		return 0
	fi
	
	#echo index=$index
	#echo $name,$size,$loca,$fs_type
	
	pt_name_arr[$index]=$name
	pt_size_arr[$index]=$size
	pt_locate_arr[$index]=$loca
	pt_fs_arr[$index]=$fs_type
	
	return 1
}

#@in  1: partition name
#@out 2: partition size
#@out 3: partition locate
#@out 4: partition filesystem type
function get_partition_info_by_name()
{
	name=$1
	size="null"
	loca="null"
	fs_type="null"
	index=100
	
	get_pt_name_index $name index
	is_valid_partition_index $index
	if [ $? != 1 ];then
		return 0
	fi
	
	get_partition_info_by_index $index name size loca fs_type
	eval $2=$size
	eval $3=$loca
	eval $4=$fs_type
	
	return 1
}

#@in  1: partition name
#@in  2: partition size
#@in  3: partition locate
#@in  4: partition filesystem type
function set_partition_info_by_name()
{
	name="$1"
	size="$2"
	loca="$3"
	fs_type="$4"
	index=100
	
	get_pt_name_index $name index
	is_valid_partition_index $index
	if [ $? != 1 ];then
		return 0
	fi
	
	set_partition_info_by_index $index $name $size $loca $fs_type
	
	return 1
}