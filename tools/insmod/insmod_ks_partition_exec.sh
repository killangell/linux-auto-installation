#!/bin/sh

source debug.sh
source file.sh
source disk.sh
source partition_define.sh
source partition_conf_parser.sh
source partition_ks_converter.sh
source module_conf_parser.sh

KS_PARTITION_CONF_LINE=$1
MODULES_OUTPUT_DIR=$2
KS_SEGMENTS_DIR=$RUNNING_DIR/ks-segments
TEMP_DIR=/mnt/disk
PRELOAD_DIR=/mnt/preload

KS_FORMAT="ks:mode:destination:source_file"

g_max_partition_name="null"
g_max_partition_size="null"
g_max_partition_loca="null"
g_max_partition_fs_type="null"
g_mops_phase_partition_num="null"
g_lvm_vgname="null"
	
#If object=ks, the format shoule be KS_FORMAT
#If object=inirtd, ...
#If object=iso, ...

#@in  1: Partition conf from module
#@in  2: Output dir
#@out 3: Output file
#return: true(1)/false(0)
function do_partition_sizing()
{
	conf_file=$1
	output_dir=$2
	output_file=$output_dir/partition_sizing.out
	
	print_ln LEVEL_INFO "func:$FUNCNAME,$conf_file"
	
	dest_drive="null"
	name="null"
	size="null"
	loca="null"
	fs_type="null"
	
	#Read partition conf and save 
	get_conf_dest_drive $conf_file dest_drive
	print_ln LEVEL_INFO "do rd dest_drive: $dest_drive"
	set_dest_drive $dest_drive
	
	pt_name_index=1	
	for pt_name_iterator in ${pt_name_arr[*]}  
	do  
		name=${pt_name_iterator}		
		get_conf_partition_info_by_name $conf_file $name size loca fs_type		
		if [ $name = "swap" ];then
			if [ $size = "?" ];then
				mem_size="null"
				mem_unit="null"
				get_memory_size mem_size mem_unit
				
				size=$(echo "2*$mem_size" | bc -l)"M"
			fi
		fi
		
		print_ln LEVEL_INFO "do rd partition $pt_name_index: $name,$size,$loca,$fs_type"
		
		set_partition_info_by_name $name $size $loca $fs_type
		
		let pt_name_index=$pt_name_index+1
	done 
	
	#Output to file
	print_ln LEVEL_INFO "Output to $output_file"
	
	rm -rf $output_file
	
	get_dest_drive dest_drive
	print_ln LEVEL_INFO "do wr dest_drive: $dest_drive"
	echo dest_drive=$dest_drive >> $output_file
	
	pt_name_index=1
	for pt_name_iterator in ${pt_name_arr[*]}  
	do  
		name=${pt_name_iterator}		
		get_partition_info_by_name $name size loca fs_type		
	
		print_ln LEVEL_INFO "do wr partition $pt_name_index: $name,$size,$loca,$fs_type"
		echo $name:$size:$loca:$fs_type  >> $output_file
		
		let pt_name_index=$pt_name_index+1
	done 
	
	eval $3=$output_file
	
	return 1
}

#@in  1: Input ks partition file
#@out 2: Output mops pattition file 
function get_mops_phase_partition_code()
{
	ks_partition_file=$1
	mops_phase_partition_file=$2
	
	print_ln LEVEL_INFO "func:$FUNCNAME"
	print_ln LEVEL_INFO "ks_partition_file=$ks_partition_file"
	print_ln LEVEL_INFO "mops_phase_partition_file=$mops_phase_partition_file"
	
	ks_partition_num=`cat $ks_partition_file | grep ^part | wc -l`
	print_ln LEVEL_INFO "ks_partition_num=$ks_partition_num"

	get_dest_drive dest_drive
	
	temp_string="parted -a opt /dev/$dest_drive -s mklabel gpt"
	print_ln LEVEL_INFO "wr2file mops phase partition: $temp_string"					
	echo "$temp_string" >> $mops_phase_partition_file
	
	start_pos=0
	for((i=0;i<$ks_partition_num;i++));do
		let end_pos=$start_pos+300
		spos=$start_pos"MB"
		epos=$end_pos"MB"
		
		temp_string="parted -a opt /dev/$dest_drive -s mkpart primary $spos $epos"
		print_ln LEVEL_INFO "wr2file mops phase partition: $temp_string"					
		echo "$temp_string" >> $mops_phase_partition_file
	
		start_pos=$end_pos
	done

	get_disk_size $dest_drive size unit
	#echo size=$size,unit=$unit

	#This partition is used to store ISO source file
	let iso_partition_start=$size-10
	spos=$iso_partition_start"GB"
	
	temp_string="parted -a opt /dev/$dest_drive -s mkpart primary $spos 100%"
	print_ln LEVEL_INFO "wr2file mops phase partition: $temp_string"					
	echo "$temp_string" >> $mops_phase_partition_file
	
	let g_mops_phase_partition_num=$ks_partition_num+1
	
	return 1
}

#@in  1: Mops pattition file 
#@out 2: Partition number 
function get_mops_phase_partition_num()
{
	mops_phase_partition_file=$1
	mops_phase_partition_num=`cat $mops_phase_partition_file | grep ^parted | wc -l`
	
	#echo mops_phase_partition_num=$mops_phase_partition_num
	eval $2=$mops_phase_partition_num
	print_ln LEVEL_INFO "func:$FUNCNAME mops_phase_partition_num=$mops_phase_partition_num"
	
	return 1
}

#@in  1: Destination drive
#@in  2: Input mops pattition file
#@out 3: Output ks-pre partition code 
function get_ks_pre_phase_code()
{
	dest_drive=$1
	mops_phase_partition_codex=$2
	ks_pre_partition_codex=$3
	mops_phase_partition_num="null"
	
	get_mops_phase_partition_num $mops_phase_partition_codex mops_phase_partition_num
	let delete_mops_phase_partition_num=$mops_phase_partition_num-2
	let last_mops_phase_partition_num=$mops_phase_partition_num-1
	print_ln LEVEL_INFO "func:$FUNCNAME delete_mops_phase_partition_num=$delete_mops_phase_partition_num"	
	for((i=0;i<$delete_mops_phase_partition_num;i++));do
		let delete_partition_index=$i+1
		temp_string="parted /dev/$dest_drive rm $delete_partition_index"
		print_ln LEVEL_INFO "wr2file ks-pre partition code: $temp_string"					
		echo "$temp_string" >> $ks_pre_partition_codex
	done
	
	full_device="/dev/$dest_drive$last_mops_phase_partition_num"
	
	temp_string="mkdir -p $TEMP_DIR $PRELOAD_DIR"
	print_ln LEVEL_INFO "wr2file ks-pre partition code: $temp_string"					
	echo "$temp_string" >> $ks_pre_partition_codex	
	
	temp_string="mount $full_device $TEMP_DIR"
	print_ln LEVEL_INFO "wr2file ks-pre partition code: $temp_string"					
	echo "$temp_string" >> $ks_pre_partition_codex	
	
	temp_string="cp $TEMP_DIR/rc.local $PRELOAD_DIR"
	print_ln LEVEL_INFO "wr2file ks-pre partition code: $temp_string"					
	echo "$temp_string" >> $ks_pre_partition_codex
	
	temp_string="umount $full_device -l"
	print_ln LEVEL_INFO "wr2file ks-pre partition code: $temp_string"					
	echo "$temp_string" >> $ks_pre_partition_codex

	return 1
}

#@in  1: Destination drive
#@out 2: Output ks-post partition code
function get_nolvm_partition_resizing_code()
{
	print_ln LEVEL_INFO "func:$FUNCNAME g_mops_phase_partition_num=$g_mops_phase_partition_num"	
	
	delete_partition_index1=$g_mops_phase_partition_num
	let delete_partition_index2=$g_mops_phase_partition_num-1
	
	dest_drive=$1	
	ks_post_partition_codex=$2
	
	#Step 1:
	second_last_end_size="null"
	get_disk_partition_end_size "$dest_drive" "$delete_partition_index2" second_last_end_size
	
	print_ln LEVEL_INFO "partition_index=$delete_partition_index2,second_last_end_size=$second_last_end_size"	
	
	#Setp 2：	
	temp_string="parted /dev/$dest_drive rm $delete_partition_index1"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	temp_string="parted /dev/$dest_drive rm $delete_partition_index2"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	#Setp 3:
	temp_string="parted -a opt /dev/$dest_drive -s mkpart primary $second_last_end_size 100%"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	resize_device=$dest_drive$delete_partition_index2
	temp_string="/sbin/e2fsck -p -f /dev/$resize_device"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex	
	
	temp_string="/sbin/resize2fs /dev/$resize_device"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	return 1
}

#@in  1: Destination drive
#@out 2: Output ks-post partition code
#@out 3: Output rc.local kickoff code
function get_lvm_partition_resizing_code()
{
	dest_drive=$1	
	ks_post_partition_codex=$2
	kickoff_codex=$3
	
	print_ln LEVEL_INFO "func:$FUNCNAME g_mops_phase_partition_num=$g_mops_phase_partition_num"	
	
	delete_partition_index1=$g_mops_phase_partition_num
	let delete_partition_index2=$g_mops_phase_partition_num-1
	
	dest_drive=$1	
	ks_post_partition_codex=$2
	kickoff_file=$3
	
	pv_size="null"
	pv_unit="null"
	new_pv_size="null"
	new_pv_unit="null"
	
	#Step 1:
	second_last_end_size="null"
	get_disk_partition_end_size "$dest_drive" "$delete_partition_index2" second_last_end_size
	print_ln LEVEL_INFO "partition_index=$delete_partition_index2,second_last_end_size=$second_last_end_size"	
	
	get_pv_size "$dest_drive" "$delete_partition_index2" pv_size pv_unit
	print_ln LEVEL_INFO "pv:$dest_drive$delete_partition_index2,pv_size=$pv_size,pv_unit=$pv_unit"
	
	get_disk_pv_capability "$dest_drive" "$delete_partition_index1" new_pv_size new_pv_unit
	print_ln LEVEL_INFO "pv:$dest_drive$delete_partition_index1,new_pv_size=$new_pv_size,new_pv_unit=$new_pv_unit"
	
	#Setp 2：	
	temp_string="parted /dev/$dest_drive rm $delete_partition_index1"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	temp_string="parted /dev/$dest_drive rm $delete_partition_index2"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	#Setp 3:
	temp_string="parted -a opt /dev/$dest_drive -s mkpart primary $second_last_end_size 100%"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	temp_string="parted /dev/$dest_drive set $delete_partition_index2 LVM on"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	#set -x
	#Setp 4:
	resize_device=$dest_drive$delete_partition_index2
	if [ "$pv_unit" = "$new_pv_unit" ];then
		let total_size=$pv_size+$new_pv_size
		total_unit="G"
		if [ "$pv_unit" = "MiB" ];then
			total_unit="M"
		fi
	elif [ "$pv_unit" = "GiB" ];then
		let total_size=$pv_size*1000+$new_pv_size
		total_unit="M"
	elif [ "$pv_unit" = "MiB" ];then
		let total_size=$pv_size+$new_pv_size*1000
		total_unit="M"
	fi
	total_physize=$total_size$total_unit
	#set +x
	
	temp_string="pvresize --setphysicalvolumesize $total_physize /dev/$resize_device"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	
	lvm_full_resize_device="/dev/$g_lvm_vgname/lv_$g_max_partition_name"
	
	temp_string="lvresize -rl +100%FREE $lvm_full_resize_device"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	temp_string="dmsetup resume $lvm_full_resize_device"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex

	###
	temp_string="mv /mnt/sysimage/etc/rc.d/rc.local /mnt/sysimage/etc/rc.d/rc.local.back"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	temp_string="cp -rf $PRELOAD_DIR/rc.local /mnt/sysimage/etc/rc.d/"
	print_ln LEVEL_INFO "wr2file ks-post partition code: $temp_string"					
	echo "$temp_string" >> $ks_post_partition_codex
	
	###
	temp_string="umount $lvm_full_resize_device -l >> /root/resize.log"
	print_ln LEVEL_INFO "wr2file rc.local code: $temp_string"					
	echo "$temp_string" >> $kickoff_file
	
	temp_string="/sbin/e2fsck -p -f $lvm_full_resize_device  >> /root/resize.log"
	print_ln LEVEL_INFO "wr2file rc.local code: $temp_string"					
	echo "$temp_string" >> $kickoff_file
	
	temp_string="/sbin/resize2fs $lvm_full_resize_device  >> /root/resize.log"
	print_ln LEVEL_INFO "wr2file rc.local code: $temp_string"					
	echo "$temp_string" >> $kickoff_file
	
	mount_point="null"
	get_partition_mount_point_by_name $g_max_partition_name mount_point

	temp_string="mount $lvm_full_resize_device $mount_point >> /root/resize.log"
	print_ln LEVEL_INFO "wr2file rc.local code: $temp_string"					
	echo "$temp_string" >> $kickoff_file
	
	temp_string="mv /etc/rc.d/rc.local /root/rc.local.todel"
	print_ln LEVEL_INFO "wr2file rc.local code: $temp_string"					
	echo "$temp_string" >> $kickoff_file
	
	temp_string="mv /etc/rc.d/rc.local.back /etc/rc.d/rc.local"
	print_ln LEVEL_INFO "wr2file rc.local code: $temp_string"					
	echo "$temp_string" >> $kickoff_file

	return 1
}

#@in  1: Destination drive
#@out 2: Output ks-post partition code
#@out 3: Output rc.local kickoff code
function get_ks_post_phase_code()
{
	if [ "$max_partition_loca" = "lvm" ]; then		
		get_lvm_partition_resizing_code $1 $2 $3
	else
		get_nolvm_partition_resizing_code $1 $2
	fi
	
	return 1
}

#@in  1: Partition conf from module
#@in  2: Output dir
#@out 3: Output file
#return: true(1)/false(0)
function do_partition_action()
{
	partition_final_file=$1
	ks_segments_dir=$2
	
	ks_segments_partition_file=$ks_segments_dir/partition.out
	ks_segments_harddrive_file=$ks_segments_dir/harddrive.out
	ks_segments_bootloader_file=$ks_segments_dir/bootloader.out	
	mops_partitioin_code_file=$ks_segments_dir/mops_partition_code.out		
	ks_pre_partitioin_code_file=$ks_segments_dir/pre_partition_code.out		
	ks_post_partitioin_code_file=$ks_segments_dir/post_partition_code.out	
	kickoff_code_file=$ks_segments_dir/rc.local.out
	rm -rf $ks_segments_partition_file
	rm -rf $ks_segments_harddrive_file
	rm -rf $ks_segments_bootloader_file
	rm -rf $mops_partitioin_code_file
	rm -rf $ks_pre_partitioin_code_file
	rm -rf $ks_post_partitioin_code_file
	rm -rf $kickoff_code_file
	
	#The biggest partition shoule be placed at last of the partition segment.
	max_partition_name="null"
	max_partition_size="null"
	max_partition_loca="null"
	max_partition_fs_type="null"
	
	#print_ln LEVEL_INFO "func:$FUNCNAME,$partition_final_file,$ks_segments_dir"	
	print_ln LEVEL_INFO "func:$FUNCNAME"	
	
	dest_drive="null"
	temp_string="null"	
	lvm_created_partition_flag="false"
	lvm_vg_name="vg0"
	g_lvm_vgname=$lvm_vg_name
	
	#Step 1: Create ks-segments partition
	get_dest_drive dest_drive
	#print_ln LEVEL_INFO "dest_drive=$dest_drive"	
	if [ "null" = "$dest_drive" ];then
		print_ln LEVEL_FATAL "Get destination drive failed"
		return 0
	fi
	
	temp_string="clearpart --all --drives=$dest_drive"
	print_ln LEVEL_INFO "wr2file partition: $temp_string"
	echo "$temp_string" >> $ks_segments_partition_file
	
	temp_string="ignoredisk --only-use=$dest_drive"
	print_ln LEVEL_INFO "wr2file partition: $temp_string"
	echo "$temp_string" >> $ks_segments_partition_file
	
	#echo "clearpart --all --drives=$dest_drive" >> $ks_segments_partition_file
	#echo "ignoredisk --only-use=$dest_drive" >> $ks_segments_partition_file
	
	exec_pt_name_index=1
	for exec_pt_name_iterator in ${pt_name_arr[*]}  
	do  
		exec_pt_name=${exec_pt_name_iterator}
		exec_pt_size="null"
		exec_pt_loca="null"
		exec_pt_fs_type="null"
		
		get_partition_info_by_name $exec_pt_name exec_pt_size exec_pt_loca exec_pt_fs_type
		if [ "0" = "$exec_pt_size" ];then
			continue
		fi
	
		#print_ln LEVEL_INFO "do wr2file $exec_pt_name_index: $exec_pt_name"
		
		if [ $exec_pt_size = "max" ];then
			max_partition_name=$exec_pt_name
			max_partition_size=$exec_pt_size
			max_partition_loca=$exec_pt_loca
			max_partition_fs_type=$exec_pt_fs_type
			
			g_max_partition_name=$exec_pt_name
			g_max_partition_size=$exec_pt_size
			g_max_partition_loca=$exec_pt_loca
			g_max_partition_fs_type=$exec_pt_fs_type
		else
			if [ $exec_pt_loca = "disk" ];then
				get_ks_disk_partition_string $exec_pt_name $exec_pt_size $exec_pt_fs_type temp_string
			else
				if [ $lvm_created_partition_flag = "false" ];then
					temp_string="part pv.008019 --grow --size=1"
					print_ln LEVEL_INFO "wr2file partition: $temp_string"
					echo "$temp_string" >> $ks_segments_partition_file
	
					temp_string="volgroup $lvm_vg_name --pesize=4096 pv.008019"
					print_ln LEVEL_INFO "wr2file partition: $temp_string"
					echo "$temp_string" >> $ks_segments_partition_file
					
					#echo "part pv.008019 --grow --size=1" >> $ks_segments_partition_file
					#echo "volgroup $lvm_vg_name --pesize=4096 pv.008019" >> $ks_segments_partition_file
					lvm_created_partition_flag="true" #Only create one time
				fi
				get_ks_lvm_partition_string $exec_pt_name $exec_pt_size $exec_pt_fs_type $lvm_vg_name temp_string
			fi
			
			temp_string=$(echo $temp_string | sed 's/+/ /g')
			print_ln LEVEL_INFO "wr2file partition: $temp_string"
			echo "$temp_string" >> $ks_segments_partition_file
		fi
		
		let exec_pt_name_index=$exec_pt_name_index+1
	done 
	
	if [ "null" != "$max_partition_name" ];then
		print_ln LEVEL_INFO "$max_partition_name is the biggest partition"
		if [ $max_partition_loca = "disk" ];then
			get_ks_disk_partition_string $max_partition_name $max_partition_size $max_partition_fs_type temp_string
		else
			get_ks_lvm_partition_string $max_partition_name $max_partition_size $max_partition_fs_type $lvm_vg_name temp_string
		fi
		temp_string=$(echo $temp_string | sed 's/+/ /g')
		print_ln LEVEL_INFO "wr2file partition: $temp_string"
		echo "$temp_string" >> $ks_segments_partition_file
	fi
	print_ln LEVEL_INFO "Check partition file: $ks_segments_partition_file"
	
	get_dest_drive dest_drive

	#Step 2: Create ks-segments harddrive	
	mops_phase_partition_file=$mops_partitioin_code_file
	
	get_mops_phase_partition_code $ks_segments_partition_file $mops_phase_partition_file
	
	get_mops_phase_partition_num $mops_phase_partition_file prel_parted_num
	let prel_iso_partition_num=$prel_parted_num-1
	harddrive_str="$dest_drive$prel_iso_partition_num"
	
	get_ks_harddrive_string $harddrive_str temp_string
	temp_string=$(echo $temp_string | sed 's/+/ /g')
	print_ln LEVEL_INFO "wr2file harddrive: $temp_string"
	echo "$temp_string" >> $ks_segments_harddrive_file
	print_ln LEVEL_INFO "Check harddrive file: $ks_segments_harddrive_file"
	
	#Step 3: Create ks-segments bootloader
	get_ks_bootloader_string $dest_drive temp_string
	temp_string=$(echo $temp_string | sed 's/+/ /g')
	print_ln LEVEL_INFO "wr2file bootloader: $temp_string"
	echo "$temp_string" >> $ks_segments_bootloader_file
	print_ln LEVEL_INFO "Check bootloader file: $ks_segments_bootloader_file"
	
	#Step 4: Create ks-pre code
	get_ks_pre_phase_code $dest_drive $mops_partitioin_code_file $ks_pre_partitioin_code_file
	print_ln LEVEL_INFO "Check ks-pre file: $ks_pre_partitioin_code_file"
	
	#Step 5: Create ks-post code
	get_ks_post_phase_code $dest_drive $ks_post_partitioin_code_file $kickoff_code_file
	print_ln LEVEL_INFO "Check ks-post file: $ks_post_partitioin_code_file"
	print_ln LEVEL_INFO "Check rc.local file: $kickoff_code_file"
	
	return 1
}

#@in  1: Partition conf from module
#@in  2: Output dir
#return: true(1)/false(0)
function do_ks_partition_process()
{
	conf_file=$1
	output_dir=$2	
	sizing_out="null"
	
	print_ln LEVEL_INFO "func:$FUNCNAME,$conf_file"
	
	do_partition_sizing $conf_file $output_dir sizing_out
	if [ $? -ne 1 ];then
		print_ln LEVEL_INFO "do_partition_sizing failed"
		return  0
	fi
	
	do_partition_action $sizing_out $KS_SEGMENTS_DIR
	if [ $? -ne 1 ];then
		print_ln LEVEL_INFO "do_partition_action failed"
		return  0
	fi
	
	return 1
}

show_sh_begin_banner

do_ks_partition_process $KS_PARTITION_CONF_LINE $MODULES_OUTPUT_DIR
if [ $? -ne 1 ];then
	print_ln LEVEL_INFO "do_ks_partition_process failed"
	exit 0
fi

show_sh_end_banner

exit 1
