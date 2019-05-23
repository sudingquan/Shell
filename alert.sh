#!/bin/bash
start_min=`date +%M`
i=1
while [[ 1 ]]; do
    echo "wake up"
    hour=`date +%H`
    min=`date +%M`
    sec=`date +%S`
    printf "now : %s:%s:%s\n" ${hour} ${min} ${sec}
    if [[ ${min} -eq $[(${start_min}+1*${i})%60] ]]; then
        echo "It's time to rest"
        i=$[${i}+1]
    fi
    if [[ ${min} -eq 0 ]]; then
        printf "now : %s : %s\n" ${hour} ${min}
    fi
    echo "sleep..."
    sleep 45s
done
