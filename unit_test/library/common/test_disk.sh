source debug.sh
source disk.sh


#Global define, should be unique in system
test_disk_func_index="null"
test_disk_func_arr="null"
test_disk_func_iterator="null"

UNIT_TEST_DIR=$RUNNING_DIR/unit_test/library/common
mkdir -p $UNIT_TEST_DIR

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
" > $UNIT_TEST_LIB_COM_DIR/disk_size_string1
	expect_size="21"
	expect_unit="GB"	
	real_size="null"
	real_unit="null"
	
	parse_disk_size_file $UNIT_TEST_LIB_COM_DIR/disk_size_string1 real_size real_unit
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
" > $UNIT_TEST_LIB_COM_DIR/disk_size_string2
	expect_size="500"
	expect_unit="MB"	
	real_size="null"
	real_unit="null"
	
	parse_disk_size_file $UNIT_TEST_LIB_COM_DIR/disk_size_string2 real_size real_unit
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

#Test list
test_disk_func_arr=(
	test_parse_disk_size_string_1
	#test_parse_disk_size_string_2 ###???
	test_get_memory_size
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

