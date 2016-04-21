#!/bin/sh

source debug.sh
source test_file.sh
source test_module_conf_parser.sh

#Global define, should be unique in system
unit_test_func_index="null"
unit_test_func_arr="null"
unit_test_func_iterator="null"

show_sh_begin_banner


#Test list
unit_test_func_arr=(
	test_file_all_funcs
	test_module_conf_parser_all_funcs
)

unit_test_func_index=1
for unit_test_func_iterator in ${unit_test_func_arr[*]}  
do  
	print_head LEVEL_INFO "list $unit_test_func_index: ${unit_test_func_iterator} begin...\n"
	${unit_test_func_iterator}
	if [ $? -eq 0 ];then
		print_head LEVEL_INFO "list $unit_test_func_index: ${unit_test_func_iterator} failed!!!\n\n"
	else
		print_head ERROR_INFO "list $unit_test_func_index: ${unit_test_func_iterator} passed...\n\n"
	fi
	
	let unit_test_func_index=$unit_test_func_index+1
done 


show_sh_end_banner