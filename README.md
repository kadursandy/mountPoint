mountPoint
==========

Compare Linux mount points and execute mount points for the missing.


This script will compare the two host lists passed as arguments, compare the mount points and executes the mounts points for the missing ones.
This is useful for Administrators who have a bunch of testing servers ,Eg:/home/appuser mount point to be created in different enviornments and maintain them.

Usage:
perl compare_and_exec_missing_mounts.pl hostlist1.txt hostlist2.txt 

Here hostlist1.txt has all the mount points
hostlist2.txt  the list which is compared against the host of hostlist1.txt 

Correspondings hosts are compared b/w hostlist1.txt with hostlist2.txt
