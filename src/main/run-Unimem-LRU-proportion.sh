#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.9" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.1" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-9-1-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-9-1-${i}out ${workloads}-cache_miss ${workloads}-Unimem-9-1-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.8" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.2" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-8-2-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-8-2-${i}out ${workloads}-cache_miss ${workloads}-Unimem-8-2-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.7" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.3" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-7-3-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-7-3-${i}out ${workloads}-cache_miss ${workloads}-Unimem-7-3-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.6" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.4" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-6-4-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-6-4-${i}out ${workloads}-cache_miss ${workloads}-Unimem-6-4-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.5" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.5" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-5-5-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-5-5-${i}out ${workloads}-cache_miss ${workloads}-Unimem-5-5-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.4" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.6" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-4-6-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-4-6-${i}out ${workloads}-cache_miss ${workloads}-Unimem-4-6-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.3" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.7" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-3-7-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-3-7-${i}out ${workloads}-cache_miss ${workloads}-Unimem-3-7-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" ../main/Unimem-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.2" ../main/Unimem-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.8" ../main/Unimem-proportion.cpp
	# head ../main/Unimem-proportion.cpp
	g++ -g -o bip-${workloads}-2-8-${i}out ../main/Unimem-proportion.cpp
    ./bip-${workloads}-2-8-${i}out ${workloads}-cache_miss ${workloads}-Unimem-2-8-${i}out	
done