source debug.sh
source partition_define.sh


#Global define, should be unique in system
test_partition_define_func_index="null"
test_partition_define_func_arr="null"
test_partition_define_func_iterator="null"

UNIT_TEST_TMP_DIR=$RUNNING_DIR/unit_test

#set -xv

#return: true(1)/false(0)
function test_get_dest_drive()
{
	expect="sda"
	real="null"
	
	get_dest_drive real
	
	if [ $expect != $real ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_set_dest_drive()
{
	expect="hda"
	real="null"
	old_drive="null"
	
	get_dest_drive old_drive
	set_dest_drive $expect
	get_dest_drive real
	#Set to default
	set_dest_drive $old_drive
	
	if [ $expect != $real ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_pt_name_index()
{
	index="-1"
	
	get_pt_name_index efi index
	if [ $index -ne 0 ];then
		return 0 
	fi
	
	get_pt_name_index root index
	if [ $index -ne 3 ];then
		return 0 
	fi
	
	
	return 1 
}

#return: true(1)/false(0)
function test_is_valid_partition_index()
{
	index=0
	expect=1
	is_valid_partition_index $index 
	if [ $? -ne $expect ];then
		return 0
	fi
	
	index=5
	expect=1
	is_valid_partition_index $index 
	if [ $? -ne $expect ];then
		return 0
	fi
	
	index=9
	expect=1
	is_valid_partition_index $index
	if [ $? -ne $expect ];then
		return 0
	fi
	
	index=15
	expect=0
	is_valid_partition_index $index
	if [ $? -ne $expect ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_partition_info_by_index_1()
{
	index=0
	
	expect_name="efi"
	expect_size="200M"
	expect_loca="disk"
	expect_fs_type="vfat"
	
	real_name="null"
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_index $index real_name real_size real_loca real_fs_type
	#echo $real_name,$real_size,$real_loca,$real_fs_type
	if [ $expect_name != $real_name ];then
		return 0
	fi
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
function test_get_partition_info_by_index_2()
{
	index=3
	
	expect_name="root"
	expect_size="10G"
	expect_loca="lvm"
	expect_fs_type="ext4"
	
	real_name="null"
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_index $index real_name real_size real_loca real_fs_type
	if [ $expect_name != $real_name ];then
		return 0
	fi
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
function test_get_partition_info_by_index_3()
{
	index=9
	
	expect_name="data"
	expect_size="0"
	expect_loca="lvm"
	expect_fs_type="ext4"
	
	real_name="null"
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_index $index real_name real_size real_loca real_fs_type
	if [ $expect_name != $real_name ];then
		return 0
	fi
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
function test_set_partition_info_by_index_1()
{
	index=9
	
	expect_name="data"
	expect_size="1G"
	expect_loca="disk"
	expect_fs_type="ext3"
	
	real_name="null"
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	old_name="null"
	old_size="null"
	old_loca="null"
	old_fs_type="null"
	
	get_partition_info_by_index $index old_name old_size old_loca old_fs_type
	set_partition_info_by_index $index $expect_name $expect_size $expect_loca $expect_fs_type	
	get_partition_info_by_index $index real_name real_size real_loca real_fs_type
	#echo $real_name,$real_size,$real_loca,$real_fs_type
	#Set default value again
	set_partition_info_by_index $index $expect_name $old_size $old_loca $old_fs_type
	
	if [ $expect_name != $real_name ];then
		return 0
	fi
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
function test_get_partition_info_by_name_1()
{
	name="efi"
	
	expect_size="200M"
	expect_loca="disk"
	expect_fs_type="vfat"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_name $name real_size real_loca real_fs_type
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
function test_get_partition_info_by_name_2()
{
	name="home"
	
	expect_size="20G"
	expect_loca="lvm"
	expect_fs_type="ext4"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_name $name real_size real_loca real_fs_type
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
function test_get_partition_info_by_name_3()
{
	name="data"
	
	expect_size="0"
	expect_loca="lvm"
	expect_fs_type="ext4"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_name $name real_size real_loca real_fs_type
	#echo $name,$real_size,$real_loca,$real_fs_type
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
function test_get_partition_info_by_name_4()
{
	name="xxx"
	
	expect_size="null"
	expect_loca="null"
	expect_fs_type="null"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	get_partition_info_by_name $name real_size real_loca real_fs_type
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
function test_set_partition_info_by_name_1()
{
	name="data"
	
	expect_size="3G"
	expect_loca="disk"
	expect_fs_type="ext2"
	
	real_size="null"
	real_loca="null"
	real_fs_type="null"
	
	old_size="null"
	old_loca="null"
	old_fs_type="null"
	
	get_partition_info_by_name $name old_size old_loca old_fs_type	
	set_partition_info_by_name $name $expect_size $expect_loca $expect_fs_type
	get_partition_info_by_name $name real_size real_loca real_fs_type
	#Set default value again
	set_partition_info_by_name $name $old_size $old_loca $old_fs_type
	
	#echo $name,$real_size,$real_loca,$real_fs_type
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
test_partition_define_func_arr=(
	test_get_dest_drive
	test_set_dest_drive
	test_get_pt_name_index
	test_is_valid_partition_index
	test_get_partition_info_by_index_1
	test_get_partition_info_by_index_2	
	test_get_partition_info_by_index_3
	test_set_partition_info_by_index_1
	test_get_partition_info_by_name_1
	test_get_partition_info_by_name_2
	test_get_partition_info_by_name_3
	test_get_partition_info_by_name_4	
	test_set_partition_info_by_name_1
)

function test_partition_define_all_funcs()
{
	test_partition_define_func_index=1
	
	for test_partition_define_func_iterator in ${test_partition_define_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_partition_define_func_index: ${test_partition_define_func_iterator}"
		${test_partition_define_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_partition_define_func_index=$test_partition_define_func_index+1
	done 
	
	return 1
}

