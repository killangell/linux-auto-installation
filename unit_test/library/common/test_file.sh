source system.sh
source file.sh

test_result=false

# in 1: level
# in 2: info
# Desc:
function print_procx()
{
	sh_name=$0
	print_proc "$sh_name" "$1" "$2"
}
# in 1: level
# in 2: info
# Desc:
function printx()
{
	print "$1" "$2"
}

:<<FILE_1
#@out 1: true(1)/false(0)
function test_is_file_exist()
{
	print_procx LEVEL_INFO "func: $FUNCNAME"
	
	result=true
	test_file=$RUNNING_DIR/file.is_file_exist
	
	rm -rf $test_file
	is_file_exist $test_file result
	if [ $result != false ];then
		eval $1=false
		printx ERROR_INFO " ... failed at 1\n"
		exit 
	fi
	
	touch $test_file
	is_file_exist $test_file result
	if [ $result = false ];then
		eval $1=false
		printx ERROR_INFO " ... failed at 2\n"
		exit 
	fi
	
	#eval $1=true
	printx ERROR_INFO " ... passed\n"
	result=$1
	eval $result=true
}
FILE_1

#set -xv
#@out 1: true(1)/false(0)
function test_is_file_exist_1()
{
	test_file=$RUNNING_DIR/file.is_file_exist
	
	rm -rf $test_file
	is_file_exist2 $test_file
	if [ $? -ne 0 ];then
		return 0 
	fi
	
	return 1 
}
#@out 1: true(1)/false(0)
function test_is_file_exist_2()
{
	test_file=$RUNNING_DIR/file.is_file_exist
	
	touch $test_file
	is_file_exist2 $test_file
	if [ $? -ne 1 ];then
		return 0 
	fi
	
	return 1 
}

test_arr=(
	test_is_file_exist_1
	test_is_file_exist_2
)


function test_file_all()
{
	for item in ${test_arr[*]}  
	do  
		print_procx LEVEL_INFO "func: ${item}"
		${item}
		if [ $? -eq 0 ];then
			printx LEVEL_INFO " ... failed\n"
		else
			printx ERROR_INFO " ... passed\n"
		fi
	done 
}

test_file_all

show_sh_end_banner $0

exit

:<<FILE_2
#@out 1: true(1)/false(0)
function test_file_all()
{
	#print_procx LEVEL_INFO "func: $FUNCNAME start ...\n"
	
	result=true
	
	test_is_file_exist result
	
	if [ $result = "false" ];then
		eval $1=false
		#print_procx ERROR_INFO "func: $FUNCNAME ... failed\n"
		exit 
	fi
	
	eval $1=true
	#print_procx LEVEL_INFO "func: $FUNCNAME ... passed\n"
}

exit_code=0

show_sh_begin_banner $0

test_file_all test_result

if [ $test_result = "false" ];then
	print_procx ERROR_INFO "unit_test failed\n"
	exit_code=0
else
	print_procx ERROR_INFO "unit_test passed\n"
	exit_code=1
fi

show_sh_end_banner $0

exit $exit_code
FILE_2


