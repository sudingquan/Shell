#!/bin/bash
declare -a max
declare -a result
declare -a max_string_file
max=(0 0 0)
max_string_file=(0:0 0:0 0:0)
result=(0:0:0:0 0:0:0:0 0:0:0:0)
function Fliter() {
    file $1 | grep -q -w "text"
    if [[ $? -eq 0 ]];then
        echo 0
    else 
        echo 1
    fi
}
function openfile() {
    if [[ $1 -ef `echo ${max_string_file[1]} | cut -d ":" -f 2` || $1 -ef `echo ${max_string_file[2]} | cut -d ":" -f 2` || $1 -ef `echo ${max_string_file[3]} | cut -d ":" -f 2` ]]; then
        return
    fi
    for i in `cat $1 | tr -c -s "a-zA-Z" " "`; do
        if [[ ${#i} -ge ${max[1]} ]]; then
            max+=(${#i})
            max_string_file+=(${#i}:$1)
            result+=(${#i}:${i}:$1:`grep -n ${i} $1 | cut -d ":" -f 1 | head -n 1`)
            max=(`echo ${max[@]} | tr " " "\n" | sort -n | tr "\n" " "`)
            max_string_file=(`echo ${max_string_file[@]} | tr " " "\n" | sort -n -t ":" -k 1 | tr "\n" " "`)
            result=(`echo ${result[@]} | tr " " "\n" | sort -n -t ":" -k 1 | tr "\n" " "`)
            unset max[0]
            unset max_string_file[0]
            unset result[0]
        fi
    done
    #printf "openfile %s\n" $1
    return
}
function opendir() {
    #printf "opendir %s\n" $1
    ls -A $1 1>/dev/null 2>/dev/null
    if [[ $? -eq  0 ]];then 
        for i in `ls -A $1`; do
            if [[ -d $1/${i} ]]; then
                ls -A $1/${i} 1>/dev/null 2>/dev/null
                if [[ $? -eq 0 ]]; then
                    if [[ $1 == */ ]]; then
                        opendir $1${i}
                    else
                        opendir $1/${i}
                    fi
                else
                    #printf "\033[31m%s : Permission denied !\033[0m\n" $1/${i}
                    exit 1
                fi
            elif [[ -f $1/${i} ]]; then
                check=`Fliter $1/${i}`
                if [[ ${check} -eq 0 ]]; then
                    if [[ $1 == */ ]]; then
                        openfile $1${i}
                    else
                        openfile $1/${i}
                    fi
                fi
            fi
        done
    fi
    return
}

if [[ $# -eq 0 ]]; then
    #opendir "."
    #printf "%s\n" ${result[1]}
    #printf "%s\n" ${result[2]}
    #printf "%s\n" ${result[3]}
    exit 1
else
    for i in $@; do
        if [[ -d ${i} ]]; then
            continue
        elif [[ -f ${i} ]]; then
            check=`Fliter ${i}`
            if [[ check -eq 0 ]]; then
                continue
            else
                #printf "\033[31mError : %s is not a text file\033[0m\n" ${i}
                exit 1
            fi
        else
            #printf "\033[31mError : no such file or directory: %s\033[0m\n" ${i}
            exit 1
        fi
    done
    for i in $@; do
        if [[ -f ${i} ]]; then
            check=`Fliter ${i}`
            if [[ check -eq 0 ]]; then
                openfile ${i}
            fi
        elif [[ -d ${i} ]]; then
            ls -A ${i} 1>/dev/null 2>/dev/null
            if [[ $? -eq 0 ]]; then
                if [[ ${i} == */ && ${i} != / ]]; then
                    opendir ${i%*/}
                else
                    opendir ${i}
                fi
            else
                #printf "\033[31m%s : Permission denied !\033[0m\n" ${i}
                exit 1
            fi
        fi
    done
    printf "%s\n" ${result[3]}
    printf "%s\n" ${result[2]}
    printf "%s\n" ${result[1]}
fi
