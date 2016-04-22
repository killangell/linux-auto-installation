source debug.sh
source utils.sh


#Global define, should be unique in system
test_utils_func_index="null"
test_utils_func_arr="null"
test_utils_func_iterator="null"

UNIT_TEST_TMP_DIR=$RUNNING_DIR/unit_test

#set -xv
#@out 1: true(1)/false(0)
function test_get_last_item_by_split_1()
{
	full_string="/mnt/hgfs/VMShareFolder/linux-auto-installation/modules/partition"
	split="/"
	expect="partition"
	real="null"
	
	get_last_item_by_split $full_string $split real
	if [ $real != $expect ];then
		return 0 
	fi
	
	return 1 
}

#@out 1: true(1)/false(0)
function test_get_last_item_by_split_2()
{
	full_string="mnt:hgfs:VMShareFolder:linux-auto-installation:modules:partition"
	split=":"
	expect="partition"
	real="null"
	
	get_last_item_by_split $full_string $split real
	if [ $real != $expect ];then
		return 0 
	fi
	
	return 1 
}

#Test list
test_utils_func_arr=(
	test_get_last_item_by_split_1
	test_get_last_item_by_split_2
)

function test_utils_all_funcs()
{
	test_utils_func_index=1
	
	for test_utils_func_iterator in ${test_utils_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_utils_func_index: ${test_utils_func_iterator}"
		${test_utils_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_utils_func_index=$test_utils_func_index+1
	done 
	
	return 1
}

