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
RUNNING_DIR=$CURRENT_PATH/running

UNIT_TEST_DIR=unit_test
UINT_TEST_SYSTEM_DIR=$UNIT_TEST_DIR/system
UINT_TEST_LIBRARY_DIR=$UNIT_TEST_DIR/library
UINT_TEST_LIBRARY_DIR_COMMON=$UNIT_TEST_DIR/library/common
UINT_TEST_PROCESS_DIR=$UNIT_TEST_DIR/process
UINT_TEST_MODULES_DIR=$UNIT_TEST_DIR/modules
UINT_TEST_RUNNING_DIR=$UNIT_TEST_DIR/running

UNIT_TEST_DIR_ALL=$UINT_TEST_SYSTEM_DIR:$UINT_TEST_LIBRARY_DIR:$UINT_TEST_LIBRARY_DIR_COMMON:$UINT_TEST_PROCESS_DIR:$UINT_TEST_MODULES_DIR:$UINT_TEST_RUNNING_DIR

#start_block

export PATH=$PATH:$SYSTEM_DIR:$LIBRARY_DIR:$LIBRARY_DIR_COMMON:$PROCESS_DIR:$UNIT_TEST_DIR_ALL
#echo $PATH

source system/system.sh

show_sh_begin_banner $0



# Replace dos2unix
#find . ! -path "*git*" -type f | sed -i 's/^M//'

sh $UNIT_TEST_DIR/unit_test.sh
exit

cd process

sh begin_clean.sh

sh insmod_exec.sh $MODULES_DIR

#sh create_uefi_boot_part.sh

sh end_clean.sh



show_sh_end_banner $0