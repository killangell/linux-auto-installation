source debug.sh
source partition_ks_converter.sh


#Global define, should be unique in system
test_partition_ks_converter_func_index="null"
test_partition_ks_converter_func_arr="null"
test_partition_ks_converter_func_iterator="null"

UNIT_TEST_DIR=$RUNNING_DIR/unit_test/tools/kickstart/partition
mkdir -p $UNIT_TEST_DIR

#set -xv

#return: true(1)/false(0)
function test_get_ks_disk_partition_string_1()
{
	name="efi"
	size="200M"
	fs_type="vfat"

	expect="part /boot/efi --fstype=vfat --asprimary --size=200M"
	real="null"
	
	get_ks_disk_partition_string $name $size $fs_type real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	#echo expect=$expect
	#echo real=$real
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_disk_partition_string_2()
{
	name="swap"
	size="2048M"
	fs_type="ext4"

	expect="part swap --asprimary --size=2048M"
	real="null"
	
	get_ks_disk_partition_string $name $size $fs_type real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_disk_partition_string_3()
{
	name="home"
	size="max"
	fs_type="ext4"

	expect="part /home --fstype=ext4 --asprimary --grow --size=1"
	real="null"
	
	get_ks_disk_partition_string $name $size $fs_type real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_lvm_partition_string_1()
{
	name="home"
	lv_name="lv_home"
	size="20G"
	fs_type="ext4"
	vgname="vg0"
	real="null"
	
	expect="logvol /home --fstype=ext4 --vgname=vg0 --size=20G --name=lv_home"
	real="null"
	
	get_ks_lvm_partition_string $name $size $fs_type $vgname real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	#echo expect=$expect
	#echo real=$real
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_lvm_partition_string_2()
{
	name="swap"
	lv_name="lv_swap"
	size="2048M"
	fs_type="ext4"
	vgname="vg0"
	real="null"

	expect="logvol swap --vgname=vg0 --size=2048M --name=lv_swap"
	real="null"
	
	get_ks_lvm_partition_string $name $size $fs_type $vgname real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	#echo expect=$expect
	#echo real=$real
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_lvm_partition_string_3()
{
	name="root"
	lv_name="lv_root"
	size="max"
	fs_type="ext4"
	vgname="vg0"
	real="null"

	expect="logvol / --fstype=ext4 --vgname=vg0 --size=1 --grow --name=lv_root"
	real="null"
	
	get_ks_lvm_partition_string $name $size $fs_type $vgname real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_harddrive_string()
{
	iso_loca="sda7"
	real="null"

	expect="harddrive --partition=sda7 --dir="
	real="null"
	
	get_ks_harddrive_string $iso_loca real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#return: true(1)/false(0)
function test_get_ks_bootloader_string()
{
	dest_drive="hda"
	real="null"

	expect="bootloader --location=mbr --driveorder=hda --append=\"crashkernel=auto rhgb quiet\""
	real="null"
	
	get_ks_bootloader_string $dest_drive real
	#Replace plus to blank space
	real=$(echo $real | sed 's/+/ /g')
	#echo expect=$expect
	#echo real=$real
	
	if [ "$expect" != "$real" ];then
		return 0
	fi
	
	return 1
}

#Test list
test_partition_ks_converter_func_arr=(
	test_get_ks_disk_partition_string_1
	test_get_ks_disk_partition_string_2
	test_get_ks_disk_partition_string_3
	test_get_ks_lvm_partition_string_1
	test_get_ks_lvm_partition_string_2
	test_get_ks_lvm_partition_string_3
	test_get_ks_harddrive_string
	test_get_ks_bootloader_string
)

function test_partition_ks_converter_all_funcs()
{
	test_partition_ks_converter_func_index=1
	
	for test_partition_ks_converter_func_iterator in ${test_partition_ks_converter_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_partition_ks_converter_func_index: ${test_partition_ks_converter_func_iterator}"
		${test_partition_ks_converter_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_partition_ks_converter_func_index=$test_partition_ks_converter_func_index+1
	done 
	
	return 1
}

