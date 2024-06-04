#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem.cpp
	sed -i "13c #define SUBPAGE 0x1ff" ../main/Unimem.cpp
	# head ../main/Unimem.cpp
	g++ -g -o bip-${workloads}-${i}out ../main/Unimem.cpp
    ./bip-${workloads}-${i}out ${workloads}-cache_miss ${workloads}-Unimem-${i}out	
done


