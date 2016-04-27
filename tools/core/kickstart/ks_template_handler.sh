#!/bin/sh

#@in  1: Key
#@in  2: ks.cfg
#@out 3: Line number
function find_line_row_number()
{
	#speccial_key="\#"$1
	speccial_key=$1
	ks_file=$2
	line_num="null"
	
	#line_num=`sed -n "/$1/=" $2`
	line_num=`sed -n "/$speccial_key/=" $ks_file`
	
	eval $3=$line_num
	
	return 1
}

#@in 1: Key
#@in 2: Source file
#@in 3: ks.cfg
function replace_key_by_file()
{
	key=$1
	file=$2
	ks=$3
	row_num="null"
	
	find_line_row_number $key $ks row_num
	
	#echo row_num=$row_num
	
	sed -i "$row_num r $file" $ks #Insert
	
	delete_line=$row_num"d"
	sed -i "$delete_line" $ks #Delete
	
	return 1
}

#@in 1: Key
#@in 2: Source file
#@in 3: ks.cfg
function insert_file_after_key()
{
	key=$1
	file=$2
	ks=$3
	
	find_line_row_number $key $ks row_num
	
	#echo row_num=$row_num
	
	sed -i "$row_num r $file" $ks #Insert
	
	return 1
}
