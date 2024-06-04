#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "4c #define CAPACITY $((pagenum*i/100))" ../main/Page-cache.cpp
	# head ../main/Page-cache.cpp
	g++ -g -o lru-${workloads}-${i}out ../main/Page-cache.cpp
    ./lru-${workloads}-${i}out ${workloads}-cache_miss ${workloads}-Pagecache-${i}out	
done


