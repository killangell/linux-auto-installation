#!/bin/sh

source debug.sh
source file.sh
source module_conf_parser.sh

KS_CONF_LINE=$1
MODULES_OUTPUT_DIR=$2

KS_FORMAT="ks:mode:destination:source_file"

#If object=ks, the format shoule be KS_FORMAT
#If object=inirtd, ...
#If object=iso, ...


#@in  1: one line of insmod.conf coincide with KS_FORMAT 
function do_ks_process()
{
	line=$KS_CONF_LINE
	mode="null"
	destination="null"
	source_file="null"
	
	print_ln LEVEL_INFO "func:$FUNCNAME,$line"
	
	get_ks_params $line mode destination source_file
	
	print_ln LEVEL_INFO "func:$FUNCNAME,$mode,$destination,$source_file"
	
	insmod_ks_partition_exec.sh $source_file $MODULES_OUTPUT_DIR
}

show_sh_begin_banner

do_ks_process $KS_CONF_LINE $MODULES_OUTPUT_DIR

show_sh_end_banner
