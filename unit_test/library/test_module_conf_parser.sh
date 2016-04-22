#!/bin/sh

#ks:mode:destination:source_file
#initrd:...unfinished
#iso:...unfinished

source debug.sh
source module_conf_parser.sh

UNIT_TEST_TMP_DIR=$RUNNING_DIR/unit_test

#Global define, should be unique in system
test_module_conf_parser_func_index="null"
test_module_conf_parser_func_arr="null"
test_module_conf_parser_func_iterator="null"

#set -xv
#@out 1: true(1)/false(0)
function test_get_ojcect_from_conf_line
{
	line="ks:mode:destination:source_file"
	object="null"
	
	get_ojcect_from_conf_line $line object
	if [ $object != "ks" ];then
		return 0
	fi
		
	return 1 
}

#@out 1: true(1)/false(0)
function test_get_ks_params
{
	line="ks:mode:destination:source_file"
	mode="null"
	destination="null"
	source_file="null"
	
	get_ks_params $line mode destination source_file
	if [ $mode != "mode" ];then
		return 0
	fi
	if [ $destination != "destination" ];then
		return 0
	fi
	if [ $source_file != "source_file" ];then
		return 0
	fi	
		
	return 1 
}

#Test list
test_module_conf_parser_func_arr=(
	test_get_ojcect_from_conf_line
	test_get_ks_params
)

function test_module_conf_parser_all_funcs()
{
	test_module_conf_parser_func_index=1
	
	for test_module_conf_parser_func_iterator in ${test_module_conf_parser_func_arr[*]}  
	do  
		print_head LEVEL_INFO "func $test_module_conf_parser_func_index: ${test_module_conf_parser_func_iterator}"
		${test_module_conf_parser_func_iterator}
		if [ $? -eq 0 ];then
			print_body LEVEL_INFO " ... failed\n"
			return 0
		else
			print_body LEVEL_INFO " ... passed\n"
		fi
		
		let test_module_conf_parser_func_index=$test_module_conf_parser_func_index+1
	done 
	
	return 1
}