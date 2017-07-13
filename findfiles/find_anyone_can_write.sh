#!/bin/bash
function check_chars(){
	cache=`ls -ld $dir_or_file | awk '{print $1}'`
	judge_type $cache $dir_or_file
}
function judge_type(){
	#travel the var
	t_1=$1
	###any one write,* *w* *w* *w*
	###              0 123 456 789
	### get the char(begin 2,one char)
	b_1=${t_1:2:1}
	b_2=${t_1:5:1}
	b_3=${t_1:8:1}
	if [ $b_1 == $b_2 ] && [ $b_1 == $b_3 ];then
		if [ $b_1 == w ];then
			echo "Anyone can write:"$2
		fi
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
