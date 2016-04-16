#!/bin/sh

true=1
false=0

#@in  1: file_path
#@out 2: result(true/false)
function is_file_exist()
{
	file_path=$1
	result=false
	
	if [ ! -f $file_path ];then
		result=false
	else
		result=true
	fi
	
	echo $result
}

#@in  1: file_path
#@out 1: count
#Desc  : include "^#" line and "blank" line
#function get_file_all_line_count()

#@in  1: file_path
#@out 1: count
#Desc  : exclude "^#" line and "blank" line
#function get_file_useful_line_count()

#@in  1: string    (e.g. 11:22:33:44)
#@in  2: separator (e.g. :)
#@in  3: count     (e.g. 4)
#@out 4,5,6,7...
#Desc  : 
function split_string()
{
	string=$1
	separator=$2
	count=$3
	
	real_count=`echo $string | awk -F ":" '{print NF}'`
	if [ $real_count -ne $count ];then
		echo "Count can not match. $real_count != $count"
		exit $false
	fi
	
	echo count=$count
	for((i=1; i<=$count; i++)); do
		let out_index=3+i
		echo out_index=$out_index
		#eval "$out_index"=`echo $line | awk -F ":" '{print $i}'`
		eval '$out_index'=`echo $line | awk -F ":" '{print $i}'`
		#eval ${out_index}=`echo $line | awk -F ":" '{print $i}'`
		#eval ${name}_show=${range}
	done
	
	exit $true
}

#:<<file_block
###############################################################################
########################## Unit Test start ####################################
###############################################################################

############################### is_file_exist #################################
test_file=unit_test/file
###
rm -rf $test_file
result=`is_file_exist $test_file`
echo $result
###
touch $test_file
result=`is_file_exist $test_file`
echo $result

############################### split_string #################################

###

result=`split_string "11:22:33:44" : 4 a b c d`
echo $result
echo $a,$b,$c,$d


###############################################################################
########################## Unit Test end # ####################################
###############################################################################
#file_block


