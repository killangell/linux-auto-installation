#!/bin/sh

source debug.sh
source file.sh
#source partition_converter.sh

MODULES_DIRX=$1

KS_FORMAT="ks:mode:destination:source_file"

#If object=ks, the format shoule be KS_FORMAT
#If object=inirtd, ...
#If object=iso, ...

#@in  1: one line of insmod.conf
#@out 2: object
function get_ojcect_from_file
{
	line=$1
	
	#object=`echo $line | awk -F ":" '{print $1}'`
	#eval $2=`echo $line | awk -F ":" '{print $1}'`
	
	#eval $2="$object"
	#eval $2=`echo ks`
	#return 1
}

#@in  1: one line of insmod.conf
#@out 2: mode
#@out 3: destination
#@out 4: source file
function get_ks_params
{
	line=$1
	
	object=`echo $line | awk -F ":" '{print $1}'`
	mode=`echo $line | awk -F ":" '{print $2}'`
	destination=`echo $line | awk -F ":" '{print $3}'`
	source_file=`echo $line | awk -F ":" '{print $4}'`
	
	eval $2=$mode
	eval $3=$destination
	eval $4=$source_file
	return 1
}

#@in  1: one line of insmod.conf coincide with KS_FORMAT 
function do_ks_process()
{
	line=$1
	mode="null"
	destination="null"
	source_file="null"
	
	print_ln LEVEL_INFO "$FUNCNAME,$line"
	
	get_ks_params line mode destination source_file
	
	print_ln LEVEL_INFO "$FUNCNAME,$mode,$destination,$source_file"
	
	echo "xxxxxxxxxxxxxxxxxxxxxx"
}

#@in  1: one line of insmod.conf
function parse_insmod_conf()
{
	file=$1
	index=1
	
	print_ln LEVEL_INFO "$FUNCNAME,$file"
	
	while read line
	do	
		if [[ $line = *#* ]];then
			continue #Do nothing		
		elif [[ $line = "" ]];then
			continue #Do nothing
		fi
		print_ln LEVEL_INFO "line $index: $line"
		#object=`get_ojcect_from_file $line`
		#if [ $object = "ks" ];then
		#	do_ks_process $line
		#else
		#	echo 
		#fi
		let index=$index+1
	done < $file
}

show_sh_begin_banner


for dir in $MODULES_DIRX/*
do
    if [ -d $dir ];then
		print_ln LEVEL_INFO "Enter into folder $dir"
		cd $dir
		ls -l
		
		is_file_exist insmod.conf
		if [ $? -eq 1 ];then
			print_ln LEVEL_INFO "Psrseing insmod.conf"
			parse_insmod_conf insmod.conf
		fi
		
		is_file_exist insmod.sh
		if [ $? -eq 1 ];then
			print_ln LEVEL_INFO "Execute insmod.sh"
		fi
		
		cd ..
	fi
done

show_sh_end_banner