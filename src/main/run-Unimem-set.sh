#!/bin/bash
workloads=$1
pagenum=$2

array1=(100 75 50 25 10)

for i in ${array1[@]}
do
	sed -i "8c #define INDEX 0x7" ../main/Unimem-set.cpp
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-set.cpp
	# head ../main/Unimem-set.cpp
	g++ -g -o bip-${workloads}-8set-${i}out ../main/Unimem-set.cpp
    ./bip-${workloads}-8set-${i}out ${workloads}-cache_miss ${workloads}-Unimem-8set-${i}out	
done

array=(50 25 10)

for i in ${array[@]}
do
	sed -i "8c #define INDEX 0x3" ../main/Unimem-set.cpp
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-set.cpp
	# head ../main/Unimem-set.cpp
	g++ -g -o bip-${workloads}-4set-${i}out ../main/Unimem-set.cpp
    ./bip-${workloads}-4set-${i}out ${workloads}-cache_miss ${workloads}-Unimem-4set-${i}out	
done

for i in ${array[@]}
do
	sed -i "8c #define INDEX 0xf" ../main/Unimem-set.cpp
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-set.cpp
	# head ../main/Unimem-set.cpp
	g++ -g -o bip-${workloads}-16set-${i}out ../main/Unimem-set.cpp
    ./bip-${workloads}-16set-${i}out ${workloads}-cache_miss ${workloads}-Unimem-16set-${i}out	
done

