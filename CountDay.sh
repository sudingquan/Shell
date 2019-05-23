#!/bin/bash
function leap_year() {
    if [[ $[$1%4] -eq 0 ]] && [[ $[$1%100] -ne 0 ]] || [[ $[$1%400] -eq 0 ]]; then 
        echo 1
    else
        echo 0
    fi
    return
}
ans=0
for i in `seq $1 1 $[$1+$2-1]`; do
    leap=`leap_year ${i}`
    if [[ ${leap} -eq 0 ]]; then
        ans=$[${ans}+365]
    else
        ans=$[${ans}+366]
    fi
done
echo ${ans}
