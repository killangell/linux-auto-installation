#!/bin/sh

source ks_template_handler.sh

key="#bootloader"
source_file=$1
ks_file=$2

replace_key_by_file $key $source_file $ks_file