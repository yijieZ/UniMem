#!/bin/bash
workloads=$1
pagenuma=$2
pagenumb=$3
pagenumc=$4
pagenumd=$5
pagenume=$6
pagenumf=$7

# array=(100 75 50 25 10)
array=(10)

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenuma*i/100))" ../main/Unimem-subpage.cpp
	sed -i "8c #define SUBPAGE 0x7f" ../main/Unimem-subpage.cpp
	# head -n 15 ../main/Unimem-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-128B-${i}out ../main/Unimem-subpage.cpp
    ./bip-${workloads}-subpage-128B-${i}out ${workloads}-cache_miss ${workloads}-Unimem-subpage-128B-${i}out
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenumb*i/100))" ../main/Unimem-subpage.cpp
	sed -i "8c #define SUBPAGE 0xff" ../main/Unimem-subpage.cpp
	# head -n 15 ../main/Unimem-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-256B-${i}out ../main/Unimem-subpage.cpp
    ./bip-${workloads}-subpage-256B-${i}out ${workloads}-cache_miss ${workloads}-Unimem-subpage-256B-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenumc*i/100))" ../main/Unimem-subpage.cpp
	sed -i "8c #define SUBPAGE 0x1ff" ../main/Unimem-subpage.cpp
	# head -n 15 ../main/Unimem-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-512B-${i}out ../main/Unimem-subpage.cpp
    ./bip-${workloads}-subpage-512B-${i}out ${workloads}-cache_miss ${workloads}-Unimem-subpage-512B-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenumd*i/100))" ../main/Unimem-subpage.cpp
	sed -i "8c #define SUBPAGE 0x3ff" ../main/Unimem-subpage.cpp
	# head -n 15 ../main/Unimem-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-1k-${i}out ../main/Unimem-subpage.cpp
    ./bip-${workloads}-subpage-1k-${i}out ${workloads}-cache_miss ${workloads}-Unimem-subpage-1k-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenume*i/100))" ../main/Unimem-subpage.cpp
	sed -i "8c #define SUBPAGE 0x7ff" ../main/Unimem-subpage.cpp
	# head -n 15 ../main/Unimem-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-2k-${i}out ../main/Unimem-subpage.cpp
    ./bip-${workloads}-subpage-2k-${i}out ${workloads}-cache_miss ${workloads}-Unimem-subpage-2k-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenumf*i/100))" ../main/Unimem-subpage.cpp
	sed -i "8c #define SUBPAGE 0xfff" ../main/Unimem-subpage.cpp
	# head -n 15 ../main/Unimem-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-4k-${i}out ../main/Unimem-subpage.cpp
    ./bip-${workloads}-subpage-4k-${i}out ${workloads}-cache_miss ${workloads}-Unimem-subpage-4k-${i}out	
done
