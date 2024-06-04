#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "8c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-nopromote.cpp
	# head ../main/Unimem-nopromote.cpp
	g++ -g -o bip-${workloads}-4k-${i}out ../main/Unimem-nopromote.cpp
    ./bip-${workloads}-4k-${i}out ${workloads}-cache_miss ${workloads}-Unimem-nopromote-${i}out	
done


