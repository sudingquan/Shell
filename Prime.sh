#!/bin/bash
for i in `seq 0 1000`; do
    prime[i]=0
done
for ((i=2;$[ i*i ]<=1000;i++)); do
    if [[ prime[i] -eq 1 ]]; then
        continue
    fi
    for((j=$[ i*i ];j<=1000;j+=i)); do 
        prime[j]=1
    done
done
ans=0
for i in `seq 2 1000`; do
    if [[ prime[i] -eq 0 ]]; then
        echo ${i}
        ans=$[${ans}+i]
    fi
done
echo ${ans}
