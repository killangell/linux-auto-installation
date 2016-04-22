#!/bin/sh

source debug.sh
source file.sh
source module_conf_parser.sh

KS_PARTITION_CONF_LINE=$1
MODULES_OUTPUT_DIR=$2

KS_FORMAT="ks:mode:destination:source_file"

#If object=ks, the format shoule be KS_FORMAT
#If object=inirtd, ...
#If object=iso, ...


#@in  1: one line of insmod.conf coincide with KS_FORMAT 
function do_ks_partition_process()
{
	conf_file=$1
	output_dir=$2
	

}

show_sh_begin_banner

do_ks_partition_process $KS_PARTITION_CONF_LINE $MODULES_OUTPUT_DIR

show_sh_end_banner
