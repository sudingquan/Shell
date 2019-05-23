#!/bin/bash
start_min=`date +%M`
i=1
j=0
while [[ 1 ]]; do
    echo "wake up"
    hour=`date +%H`
    min=`date +%M`
    sec=`date +%S`
    if [[ ${min} -eq $[ (${start_min}+45*${i}+5*${j})%60 ] ]]; then
        printf "now : %s:%s:%s\n" ${hour} ${min} ${sec}
        echo "It's time to rest for 5 minutes"
        j=$[ ${j}+1 ]
        i=$[ ${i}+1 ]
    fi 
    if [[ ${min} -eq 0 ]]; then
        printf "now : %s : %s\n" ${hour} ${min}
    fi
    echo "sleep..."
    sleep 45s
done
