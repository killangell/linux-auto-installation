#!/bin/sh

source debug.sh
source file.sh
source module_conf_parser.sh

MODULES_DIRX=$1

KS_FORMAT="ks:mode:destination:source_file"

#If object=ks, the format shoule be KS_FORMAT
#If object=inirtd, ...
#If object=iso, ...

#@in  1: one line of insmod.conf
function parse_insmod_conf_line()
{
	object="null"
	
	print_ln LEVEL_INFO "func:$FUNCNAME,$line"
	
	get_ojcect_from_conf_line $line object
	if [ $object = "ks" ];then
		insmod_ks_exec.sh $line
	else
		echo 
	fi
}

#@in  1: one line of insmod.conf
function parse_insmod_conf()
{
	file=$1
	index=1
	
	print_ln LEVEL_INFO "func:$FUNCNAME,$file"
	
	while read line
	do	
		if [[ $line = *#* ]];then
			continue #Do nothing		
		elif [[ $line = "" ]];then
			continue #Do nothing
		fi
		
		parse_insmod_conf_line $line
		
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