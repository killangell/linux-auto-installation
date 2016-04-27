source debug.sh
source ks_template_handler.sh


#Global define, should be unique in system
test_ks_template_handler_func_index="null"
test_ks_template_handler_func_arr="null"
test_ks_template_handler_func_iterator="null"

UNIT_TEST_TMP_DIR=$RUNNING_DIR/unit_test/tools/core/kickstart

mkdir -p $UNIT_TEST_TMP_DIR

test_ks_file=$UNIT_TEST_TMP_DIR/ks.cfg
test_source_bootloader=$UNIT_TEST_TMP_DIR/source_bootloader
test_source_harddrive=$UNIT_TEST_TMP_DIR/source_harddrive
test_source_partition=$UNIT_TEST_TMP_DIR/source_partition
function test_ks_template_handler_init()
{ 
rm -rf $test_ks_file
rm -rf $test_source_bootloader
rm -rf $test_source_harddrive
rm -rf $test_source_partition

echo "#harddrive
#bootloader
#partition" >> $test_ks_file

echo "bootloader --location=partition --driveorder=sda --append=\"crashkernel=auto rhgb quiet\"" >> $test_source_bootloader

echo "harddrive --partition=sda3 --dir=" >> $test_source_harddrive

echo "clearpart --all --drives=sda
ignoredisk --only-use=sda
part /boot --fstype ext4 --asprimary --size=200M
part pv.008019 --grow --size=1
volgroup vg0 --pesize=4096 pv.008019
logvol swap --vgname=vg0 --size=2048M --name=lv_swap
logvol / --vgname=vg0 --size=1G --name=lv_root
logvol /var --vgname=vg0 --size=1G --name=lv_var
logvol /home --vgname=vg0 --size=1G --name=lv_home
logvol /opt --vgname=vg0 --size=1G --name=lv_opt
logvol /usr --vgname=vg0 --size=1G --name=lv_usr
logvol /data--vgname=vg0 --size=1 --grow --name=lv_data" >> $test_source_partition
}

function test_replace_bootloader()
{
	rm -rf $test_source_bootloader.expect
	test_ks_template_handler_init
	
echo "#harddrive
bootloader --location=partition --driveorder=sda --append=\"crashkernel=auto rhgb quiet\"
#partition" >> $test_source_bootloader.expect

	key="#bootloader"
	source_file=$test_source_bootloader
	ks_file=$test_ks_file
	replace_key_by_file $key $source_file $ks_file

	diff $ks_file $test_source_bootloader.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_set_bootloader_script()
{
	rm -rf $test_source_bootloader.expect
	test_ks_template_handler_init
	
echo "#harddrive
bootloader --location=partition --driveorder=sda --append=\"crashkernel=auto rhgb quiet\"
#partition" >> $test_source_bootloader.expect

	source_file=$test_source_bootloader
	ks_file=$test_ks_file
	sh set_bootloader.sh $source_file $ks_file

	diff $ks_file $test_source_bootloader.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_replace_harddrive()
{
	rm -rf $test_source_harddrive.expect
	test_ks_template_handler_init
	
echo "harddrive --partition=sda3 --dir=
#bootloader
#partition">> $test_source_harddrive.expect

	key="#harddrive"
	source_file=$test_source_harddrive
	ks_file=$test_ks_file
	replace_key_by_file $key $source_file $ks_file

	diff $ks_file $test_source_harddrive.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_set_harddrive_script()
{
	rm -rf $test_source_harddrive.expect
	test_ks_template_handler_init
	
echo "harddrive --partition=sda3 --dir=
#bootloader
#partition">> $test_source_harddrive.expect

	source_file=$test_source_harddrive
	ks_file=$test_ks_file
	sh set_harddrive.sh $source_file $ks_file

	diff $ks_file $test_source_harddrive.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_replace_partition()
{
	rm -rf $test_source_partition.expect
	test_ks_template_handler_init
	
echo "#harddrive
#bootloader
clearpart --all --drives=sda
ignoredisk --only-use=sda
part /boot --fstype ext4 --asprimary --size=200M
part pv.008019 --grow --size=1
volgroup vg0 --pesize=4096 pv.008019
logvol swap --vgname=vg0 --size=2048M --name=lv_swap
logvol / --vgname=vg0 --size=1G --name=lv_root
logvol /var --vgname=vg0 --size=1G --name=lv_var
logvol /home --vgname=vg0 --size=1G --name=lv_home
logvol /opt --vgname=vg0 --size=1G --name=lv_opt
logvol /usr --vgname=vg0 --size=1G --name=lv_usr
logvol /data--vgname=vg0 --size=1 --grow --name=lv_data">> $test_source_partition.expect

	key="#partition"
	source_file=$test_source_partition
	ks_file=$test_ks_file
	replace_key_by_file $key $source_file $ks_file

	diff $ks_file $test_source_partition.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_set_partition_script()
{
	rm -rf $test_source_partition.expect
	test_ks_template_handler_init
	
echo "#harddrive
#bootloader
clearpart --all --drives=sda
ignoredisk --only-use=sda
part /boot --fstype ext4 --asprimary --size=200M
part pv.008019 --grow --size=1
volgroup vg0 --pesize=4096 pv.008019
logvol swap --vgname=vg0 --size=2048M --name=lv_swap
logvol / --vgname=vg0 --size=1G --name=lv_root
logvol /var --vgname=vg0 --size=1G --name=lv_var
logvol /home --vgname=vg0 --size=1G --name=lv_home
logvol /opt --vgname=vg0 --size=1G --name=lv_opt
logvol /usr --vgname=vg0 --size=1G --name=lv_usr
logvol /data--vgname=vg0 --size=1 --grow --name=lv_data">> $test_source_partition.expect

	source_file=$test_source_partition
	ks_file=$test_ks_file
	sh set_partition.sh $source_file $ks_file

	diff $ks_file $test_source_partition.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_insert_after_harddrive()
{
	rm -rf $test_source_harddrive.expect
	test_ks_template_handler_init
	
echo "#harddrive
harddrive --partition=sda3 --dir=
#bootloader
#partition">> $test_source_harddrive.expect

	key="#harddrive"
	source_file=$test_source_harddrive
	ks_file=$test_ks_file
	insert_file_after_key $key $source_file $ks_file

	diff $ks_file $test_source_harddrive.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

function test_insert_after_bootloader()
{
	rm -rf $test_source_bootloader.expect
	test_ks_template_handler_init
	
echo "#harddrive
#bootloader
bootloader --location=partition --driveorder=sda --append=\"crashkernel=auto rhgb quiet\"
#partition">> $test_source_bootloader.expect

	key="#bootloader"
	source_file=$test_source_bootloader
	ks_file=$test_ks_file
	insert_file_after_key $key $source_file $ks_file

	diff $ks_file $test_source_bootloader.expect > /dev/null
	if [ $? -ne 0 ];then
		return 0
	fi
	return 1
}

#Test list
test_ks_template_handler_func_arr=(
	test_replace_bootloader
	test_set_bootloader_script
	test_replace_harddrive
	test_set_harddrive_script
	test_replace_partition
	test_set_partition_script
	test_insert_after_harddrive
	test_insert_after_bootloader
)

function test_ks_template_handler_all_funcs()
{
	test_ks_template_handler_func_index=1
	
	for test_ks_template_handler_func_iterator in ${test_ks_template_handler_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_ks_template_handler_func_index: ${test_ks_template_handler_func_iterator}"
		${test_ks_template_handler_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_ks_template_handler_func_index=$test_ks_template_handler_func_index+1
	done 
	
	return 1
}

