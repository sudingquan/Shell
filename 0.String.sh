#!/bin/bash

length=(0 0 0)
String=(0 0 0)
File=(0 0 0)

filter_conf=./filter.conf

function filter() {
	file_type=`basename $1 | tr [.] "\n" | tail -1`
	grep -w ${file_type}  ${filter_conf}
	if [[ $? -eq 0 ]]; then
		file $1 | grep -q -w "text"
		if [[ $? -eq 0 ]]; then
			return 1
		else
			return 0
		fi
	else
		return 1
	fi
}

function find_in_file() {
	file $1 | grep text 2>&1 >/dev/null
	if [[ $? -ne 0 ]]; then
		return
	fi
	words=`cat $1 | tr -c -s "A-Za-z" "\n"`
	for i in $words; do
		temp=${#i}
		if [[ $temp -ge ${length[0]} ]]; then
			length[2]=${length[1]}
			String[2]=${String[1]}
			File[2]=${File[1]}
			length[1]=${length[0]}
			String[1]=${String[0]}
			File[1]=${File[0]}
			length[0]=$temp
			String[0]=$i
			File[0]=$1
		elif [[ $temp -ge ${length[1]} ]]; then
			length[2]=${length[1]}
			String[2]=${String[1]}
			File[2]=${File[1]}
			length[1]=$temp
			String[1]=$i
			File[1]=$1
		elif [[ $temp -ge ${length[2]} ]]; then
			length[2]=$temp
			String[2]=$i
			File[2]=$1
		fi
	done
}

function find_in_dir() {
	for i in `ls -A $1`; do
		test_same $1/$i 1 $num_args  
		if [[ $? -eq 0 ]]; then
			continue
		fi
		if [[ -f $1/$i ]]; then
			filter $1/$i
			if [[ $? -eq 0 ]]; then
				continue
			fi
			find_in_file $1/$i
		elif [[ -d $1/$i ]]; then
			find_in_dir $1/$i
		fi
	done
}

if [[ $# -eq 0 ]]; then
	echo "Usage: Words.sh file_or_dir!"
	exit 2
fi



for i in $@; do
	if [[ ! -e  $i ]]; then
		exit 1
	fi
	args+=($i)
done

num_args=$#

function test_same() {
	for (( x = $2; x < $3; x++ )); do
		if [[ $1 -ef ${args[$x]} ]]; then
			return 0
		fi
	done
	return 1
}


for i in `echo ${!args[@]}`; do
	test_same ${args[$i]} $[ $i + 1 ] $#
	if [[ $? -eq 0 ]]; then
		continue
	fi
	if [[ -d ${args[$i]} ]]; then
		find_in_dir ${args[$i]}
	elif [[ -f ${args[$i]} ]]; then
		find_in_file ${args[$i]}
	fi

done


echo "${length[0]}:${String[0]}:${File[0]}:`grep -w ${String[0]} -n ${File[0]} | head -n 1 | cut -d ":" -f 1`"
echo "${length[1]}:${String[1]}:${File[1]}:`grep -w ${String[1]} -n ${File[1]} | head -n 1 | cut -d ":" -f 1`"
echo "${length[2]}:${String[2]}:${File[2]}:`grep -w ${String[2]} -n ${File[2]} | head -n 1 | cut -d ":" -f 1`"
