#!/bin/bash
function check_chars(){
	cache=`ls -ld $dir_or_file | awk '{print $1}'`
	judge_type $cache $dir_or_file
}
function judge_type(){
	#travel the var
	t_1=$1
	###SUID/SGID 
	###SUID,* **S *** ***
	b_4=${t_1:3:1}
	###SGID,* *** **S ***
	b_5=${t_1:6:1}
	if [ $b_4 == S ] && [ $b_5 == S ];then
		echo "Have SUID and SGID:"$2
	elif [ $b_4 == S ];then
		echo "Have SUID:"$2
	elif [ $b_5 == S ];then
		echo "Have SGID:"$2
	fi
}
function getdir(){
	for element in `ls -A $1`
		do 
		dir_or_file=$1'/'$element
		if [ -d $dir_or_file ]
		then	
			check_chars $dir_or_file
			getdir $dir_or_file
		else 
			check_chars $dir_or_file
		fi
		done
}

root_dir=$1
getdir $root_dir
