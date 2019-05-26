#!/bin/bash

length=(0 0 0)
string=(0 0 0)
file=(0 0 0)

filter_conf=./filter.conf

function filter() {
    file_type=`basename $1 | tr "." "\n" | tail -n 1`
    grep -q -w ${file_type} ${filter_conf}
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

function find_file() {
    file $1 | grep -w "text" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then 
        return
    fi
    for i in `cat $1 | tr -c -s "a-zA-Z" " "`; do
        if [[ ${#i} -ge ${length[0]} ]]; then 
            length[2]=${length[1]}
			string[2]=${string[1]}
			file[2]=${file[1]}
			length[1]=${length[0]}
			string[1]=${string[0]}
			file[1]=${file[0]}
			length[0]=${#i}
			string[0]=${i}
			file[0]=$1
        elif [[ ${#i} -ge ${length[1]} ]]; then
            length[2]=${length[1]}
			string[2]=${string[1]}
			file[2]=${file[1]}
			length[1]=${#i}
			string[1]=${i}
			file[1]=$1
        elif [[ ${#i} -ge ${length[2]} ]]; then
            length[2]=${#i}
            string[2]=${i}
            file[2]=$1
        fi
    done
}

function find_dir() {
    for i in `ls -A $1`; do
        test_same $1/${i} 1 ${args}
        if [[ $? -eq 0 ]]; then 
            continue
        fi
        if [[ -f $1/$i ]]; then
            filter $1/${i}
            if [[ $? -eq 0 ]]; then
                continue
            fi
            find_file $1/${i}
        elif [[ -d $1/${i} ]]; then
            find_dir $1/$i
        fi
    done
}

if [[ $# -eq 0 ]]; then
    exit 1
fi

for i in $@; do
    if [[ ! -e $i ]]; then
        exit 1
    fi
    argv+=(${i})
done

args=$#

function test_same() {
    for (( j = $2; j < $3; j++ )); do
        if [[ $1 -ef ${argc} ]]; then
            return 0
        fi
    done
    return 1
}

for i in `echo ${!argv[@]}`; do
    test_same ${args[${i}]} $[ ${i} + 1 ] ${args}
    if [[ $? -eq 0 ]]; then
        continue
    fi
    if [[ -d ${argv[${i}]} ]]; then
        find_dir ${argv[${i}]}
    elif [[ -f ${argv[${i}]} ]]; then
        find_file ${argv[${i}]}
    fi
done

printf "%s:%s:%s:%s\n" ${length[0]} ${string[0]} ${file[0]} `grep -n -w ${string[0]} ${file[0]} | cut -d ":" -f 1 | head -n 1`
printf "%s:%s:%s:%s\n" ${length[1]} ${string[1]} ${file[1]} `grep -n -w ${string[1]} ${file[1]} | cut -d ":" -f 1 | head -n 1`
printf "%s:%s:%s:%s\n" ${length[2]} ${string[2]} ${file[2]} `grep -n -w ${string[2]} ${file[2]} | cut -d ":" -f 1 | head -n 1`
