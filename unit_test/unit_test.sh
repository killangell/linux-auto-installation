#!/bin/sh

source system.sh


show_sh_begin_banner $0


source test_file.sh

:<<UNIT_TEST_1
unit_test_arr=(
	test_file_all
)

set -xv
for item in ${unit_test_arr[*]}  
do  
	print_procx LEVEL_INFO "func: ${item}"
	echo ${item}
	${item}
	if [ $? -eq 0 ];then
		printx LEVEL_INFO " ... failed\n"
	else
		printx ERROR_INFO " ... passed\n"
	fi
done 
UNIT_TEST_1

show_sh_end_banner $0