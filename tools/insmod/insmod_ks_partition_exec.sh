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

KS_FORMAT="ks:mode:destination:source_file"

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
	rm -rf $ks_segments_partition_file
	rm -rf $ks_segments_harddrive_file
	rm -rf $ks_segments_bootloader_file
	
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
	
	#Step 1: Create ks-segments partition
	get_dest_drive dest_drive
	#print_ln LEVEL_INFO "dest_drive=$dest_drive"	
	if [ "null" = "$dest_drive" ];then
		print_ln LEVEL_FATAL "Get destination drive failed"
		return 0
	fi
	
	temp_string="clearpart --all --drives=$dest_drive"
	print_ln LEVEL_INFO "wr2file partition: $temp_string"
	echo "temp_string" >> $ks_segments_partition_file
	
	temp_string="ignoredisk --only-use=$dest_drive"
	print_ln LEVEL_INFO "wr2file partition: $temp_string"
	echo "temp_string" >> $ks_segments_partition_file
	
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
		else
			if [ $exec_pt_loca = "disk" ];then
				get_ks_disk_partition_string $exec_pt_name $exec_pt_size $exec_pt_fs_type temp_string
			else
				if [ $lvm_created_partition_flag = "false" ];then
					temp_string="part pv.008019 --grow --size=1"
					print_ln LEVEL_INFO "wr2file partition: $temp_string"
					echo "temp_string" >> $ks_segments_partition_file
	
					temp_string="volgroup $lvm_vg_name --pesize=4096 pv.008019"
					print_ln LEVEL_INFO "wr2file partition: $temp_string"
					echo "temp_string" >> $ks_segments_partition_file
					
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
	
	#Step 2: Create ks-segments partition
	
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
