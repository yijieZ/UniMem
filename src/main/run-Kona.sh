#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "6c #define INDEX $((pagenum*i/4/100))" ../main/Kona.cpp
	# head ../main/Kona.cpp
	g++ -g -o fifo-${workloads}-${i}out ../main/Kona.cpp
    ./fifo-${workloads}-${i}out ${workloads}-cache_miss ${workloads}-Kona-${i}out	
done


