source debug.sh
source partition_conf_parser.sh


#Global define, should be unique in system
test_partition_conf_parser_func_index="null"
test_partition_conf_parser_func_arr="null"
test_partition_conf_parser_func_iterator="null"

UNIT_TEST_DIR=$RUNNING_DIR/unit_test/tools/kickstart/partition
mkdir -p $UNIT_TEST_DIR

#set -xv

#return: true(1)/false(0)
function test_get_conf_dest_drive()
{
	get_conf_dest_drive_input=$UNIT_TEST_DIR/get_conf_dest_drive.input
echo "dest_drive=sda
efi:0:disk:vfat
boot:200M:disk:ext4
swap:?:lvm:ext4
root:1G:lvm:ext4
var:1G:lvm:ext4
home:1G:lvm:ext4
tmp:0:lvm:ext4
opt:1G:lvm:ext4
usr:1G:lvm:ext4
data:max:lvm:ext4" > $get_conf_dest_drive_input

	expect="sda"
	real="null"
	
	get_conf_dest_drive $get_conf_dest_drive_input real
	
	if [ $expect != $real ];then
		return 0
	fi
	
	return 1
}


#return: true(1)/false(0)
function test_get_conf_partition_info_by_name_1()
{
	get_partition_info_by_name_1_input=$UNIT_TEST_DIR/get_partition_info_by_name_1.input
echo "dest_drive=sda
efi:0:disk:vfat
boot:200M:disk:ext4
swap:?:lvm:ext4
root:1G:lvm:ext4
var:1G:lvm:ext4
home:1G:lvm:ext4
tmp:0:lvm:ext4
opt:1G:lvm:ext4
usr:1G:lvm:ext4
data:max:lvm:ext4" > $get_partition_info_by_name_1_input

	name="efi"
	
	expect_size="0"
	expect_loca="disk"
	expect_fs_type="vfat"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_conf_partition_info_by_name $get_partition_info_by_name_1_input $name real_size real_loca real_fs_type
	#echo " ",$name,$real_size,$real_loca,$real_fs_type
	if [ $expect_size != $real_size ];then
		return 0
	fi
	if [ $expect_loca != $real_loca ];then
		return 0
	fi
	if [ $expect_fs_type != $real_fs_type ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_conf_partition_info_by_name_2()
{
	get_partition_info_by_name_2_input=$UNIT_TEST_DIR/get_partition_info_by_name_2.input
echo "dest_drive=sda
efi:0:disk:vfat
boot:200M:disk:ext4
swap:?:lvm:ext4
root:1G:lvm:ext4
var:1G:lvm:ext4
home:1G:lvm:ext4
tmp:0:lvm:ext4
opt:1G:lvm:ext4
usr:1G:lvm:ext4
data:max:lvm:ext4" > $get_partition_info_by_name_2_input

	name="home"
	
	expect_size="1G"
	expect_loca="lvm"
	expect_fs_type="ext4"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_conf_partition_info_by_name $get_partition_info_by_name_2_input $name real_size real_loca real_fs_type
	#echo " ",$name,$real_size,$real_loca,$real_fs_type
	if [ $expect_size != $real_size ];then
		return 0
	fi
	if [ $expect_loca != $real_loca ];then
		return 0
	fi
	if [ $expect_fs_type != $real_fs_type ];then
		return 0
	fi
	
	return 1
}

#Test list
test_partition_conf_parser_func_arr=(
	test_get_conf_dest_drive
	test_get_conf_partition_info_by_name_1
	test_get_conf_partition_info_by_name_2
)

function test_partition_conf_parser_all_funcs()
{
	test_partition_conf_parser_func_index=1
	
	for test_partition_conf_parser_func_iterator in ${test_partition_conf_parser_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_partition_conf_parser_func_index: ${test_partition_conf_parser_func_iterator}"
		${test_partition_conf_parser_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_partition_conf_parser_func_index=$test_partition_conf_parser_func_index+1
	done 
	
	return 1
}

