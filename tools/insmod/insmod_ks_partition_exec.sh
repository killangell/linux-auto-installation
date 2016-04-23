#!/bin/sh

source debug.sh
source file.sh
source disk.sh
source partition_define.sh
source partition_conf_parser.sh
source module_conf_parser.sh

KS_PARTITION_CONF_LINE=$1
MODULES_OUTPUT_DIR=$2

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
