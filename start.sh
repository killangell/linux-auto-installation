#
#

#
# begin_clean.sh
# unit_test.sh
#

#:<<start_block
CURRENT_PATH=`pwd`
SYSTEM_DIR=$CURRENT_PATH/system
LIBRARY_DIR=$CURRENT_PATH/library
LIBRARY_DIR_COMMON=$CURRENT_PATH/library/common
PROCESS_DIR=$CURRENT_PATH/process
MODULES_DIR=$CURRENT_PATH/modules
#start_block

#export PATH=$PATH:`pwd`/process

export PATH=$PATH:$SYSTEM_DIR:$LIBRARY_DIR:$LIBRARY_DIR_COMMON:$PROCESS_DIR
#echo $PATH

source system/system.sh

show_sh_begin_banner $0



# Replace dos2unix
#find . ! -path "*git*" -type f | sed -i 's/^M//'

cd process

sh unit_test.sh

sh begin_clean.sh

sh insmod_exec.sh $MODULES_DIR

#sh create_uefi_boot_part.sh

sh end_clean.sh



show_sh_end_banner $0