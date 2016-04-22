#!/bin/sh

#@in  1: Full string    (e.g.: /mnt/hgfs/VMShareFolder/linux-auto-installation/modules/partition)
#@out 2: Split	 	    (e.g.: /)
#@out 3: The last item. (e.g.: partition)
function get_last_item_by_split()
{
	full_string=$1
	split=$2
	
	eval $3=`echo "$full_string" | awk -F "$split" '{print $NF}'`

	return 1
}


