source debug.sh
source disk.sh


#Global define, should be unique in system
test_disk_func_index="null"
test_disk_func_arr="null"
test_disk_func_iterator="null"

DISK_UNIT_TEST_DIR=$RUNNING_DIR/unit_test/library/common
mkdir -p $DISK_UNIT_TEST_DIR

#set -xv
#@out 1: true(1)/false(0)
function test_parse_disk_size_string_1()
{
echo "Model: VMware, VMware Virtual S (scsi)
Disk /dev/sda: 21.5GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  300MB   300MB                primary
 2      300MB   600MB   300MB                primary
 3      15.0GB  21.5GB  6474MB               primary
" > $DISK_UNIT_TEST_DIR/$FUNCNAME.test
	expect_size="21"
	expect_unit="GB"	
	real_size="null"
	real_unit="null"
	
	parse_disk_size_file $DISK_UNIT_TEST_DIR/$FUNCNAME.test real_size real_unit
	printf "  %s  " "$real_size,$real_unit"
	if [ $real_size != $expect_size ];then
		return 0 
	fi
	if [ $real_unit != $expect_unit ];then
		return 0 
	fi
	
	return 1 
}

#@out 1: true(1)/false(0)
function test_parse_disk_size_string_2()
{
echo "Model: VMware, VMware Virtual S (scsi)
Disk /dev/sda: 500MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  300MB   300MB                primary
 2      300MB   600MB   300MB                primary
 3      15.0GB  21.5GB  6474MB               primary
" > $DISK_UNIT_TEST_DIR/$FUNCNAME.test
	expect_size="500"
	expect_unit="MB"	
	real_size="null"
	real_unit="null"
	
	parse_disk_size_file $DISK_UNIT_TEST_DIR/$FUNCNAME.test real_size real_unit
	if [ $real_size != $expect_size ];then
		return 0 
	fi
	if [ $real_unit != $expect_unit ];then
		return 0 
	fi
	
	return 1 
}

#@out 1: true(1)/false(0)
function test_get_memory_size()
{
	mem_size="null"
	mem_unit="null"
	
	get_memory_size mem_size mem_unit
	printf "  %s  " "$mem_size,$mem_unit"
	
	return 1
}

function test_get_disk_partition_count()
{
	drive_name="sda"
	partition_count="null"
	
	get_disk_partition_count $drive_name partition_count
	
	printf "  %s  " "$drive_name,$partition_count"
	
	return 1
}

function test_parse_disk_partition_count_from_cmd()
{
echo "Model: VMware, VMware Virtual S (scsi)
Disk /dev/sda: 21.5GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  300MB   300MB                primary
 2      300MB   600MB   300MB                primary
 3      15.0GB  21.5GB  6474MB               primary
" > $DISK_UNIT_TEST_DIR/$FUNCNAME.test

	cmd="cat $DISK_UNIT_TEST_DIR/$FUNCNAME.test"
	expect=3
	real="null"
	
	parse_disk_partition_count_from_cmd "$cmd" real
	if [ $expect -ne $real ];then
		return 0
	fi
	
	return 1
}

function test_get_disk_partition_end_size()
{
	drive_name="sda"
	partition_count="null"
	partition_index="null"
	end_size="null"
	
	get_disk_partition_count $drive_name partition_count
	
	for((i=1;i<=$partition_count;i++));do
		partition_index=$i
		get_disk_partition_end_size $drive_name $partition_index end_size
		printf "  %s  " "$drive_name,$partition_index,$end_size"
	done
	
	return 1
}

function test_parse_disk_partition_end_size_from_cmd()
{
echo "Model: VMware, VMware Virtual S (scsi)
Disk /dev/sda: 21.5GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  300MB   300MB                primary
 2      300MB   600MB   300MB                primary
 3      15.0GB  21.5GB  6474MB               primary
" > $DISK_UNIT_TEST_DIR/$FUNCNAME.test

	cmd="cat $DISK_UNIT_TEST_DIR/$FUNCNAME.test"
	
	partition_index=1
	expect="300MB"
	real="null"	
	parse_disk_partition_end_size_from_cmd "$cmd" "$partition_index" real	
	if [ $expect != $real ];then
		return 0
	fi
	
	partition_index=2
	expect="600MB"
	real="null"	
	parse_disk_partition_end_size_from_cmd "$cmd" "$partition_index" real	
	if [ $expect != $real ];then
		return 0
	fi
	
	partition_index=3
	expect="21.5GB"
	real="null"	
	parse_disk_partition_end_size_from_cmd "$cmd" "$partition_index" real	
	if [ $expect != $real ];then
		return 0
	fi
	
	return 1
}

function test_parse_pv_size_from_cmd()
{
echo "  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               VolGroup
  PV Size               499.51 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              127874
  Free PE               0
  Allocated PE          127874
  PV UUID               VQsj11-jRL7-kOz1-8s2U-h9uG-gtA5-1BS95b" > $DISK_UNIT_TEST_DIR/$FUNCNAME.test

	cmd="cat $DISK_UNIT_TEST_DIR/$FUNCNAME.test"
  	drive_name="sda"	
	partition_index=2
	expect_size="499"
	expect_unit="GiB"
	real_size="null"	
	real_unit="null"	
	parse_pv_size_from_cmd "$cmd" "$drive_name" "$partition_index" real_size real_unit
	
	if [ $expect_size -ne $real_size ];then
		return 0
	fi
	
	if [ $expect_unit != $real_unit ];then
		return 0
	fi
	
	return 1
}

#Test list
test_disk_func_arr=(
	test_parse_disk_size_string_1
	#test_parse_disk_size_string_2 ###???
	test_get_memory_size
	test_get_disk_partition_count
	test_parse_disk_partition_count_from_cmd
	test_get_disk_partition_end_size
	test_parse_disk_partition_end_size_from_cmd
	test_parse_pv_size_from_cmd
)

function test_disk_all_funcs()
{
	test_disk_func_index=1
	
	for test_disk_func_iterator in ${test_disk_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_disk_func_index: ${test_disk_func_iterator}"
		${test_disk_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_disk_func_index=$test_disk_func_index+1
	done 
	
	return 1
}

