#!/bin/bash

# Simulation Average Latency configurations(ns)
Address_translation_latency=14
Host_Memory_latency=80
Device_attached_Memory_latency=150
Remote_Memory_latency_512B=2000
Remote_Memory_latency_1KB=2500
Remote_Memory_latency_2KB=3000
Remote_Memory_latency_4KB=4000
Batch_Promote_latency=$(echo "scale=2; 1987 / 512" | bc)

    # generate cache miss sequence of different workloads
    echo "start generate cache miss sequence..."
    g++ -g -o ./Facebook_ETC/l3-cache ./main/L3-Cache.cpp
    ./Facebook_ETC/l3-cache ./Facebook_ETC/Facebook_ETC.out ./Facebook_ETC/Facebook_ETC-cache_miss
    rm ./Facebook_ETC/l3-cache
    g++ -g -o ./Linear_Regression/l3-cache ./main/L3-Cache.cpp
    ./Linear_Regression/l3-cache ./Linear_Regression/Linear_Regression.out ./Linear_Regression/Linear_Regression-cache_miss
    rm ./Linear_Regression/l3-cache
    g++ -g -o ./Page_Rank/l3-cache ./main/L3-Cache.cpp
    ./Page_Rank/l3-cache ./Page_Rank/Page_Rank.out ./Page_Rank/Page_Rank-cache_miss
    rm ./Page_Rank/l3-cache
    g++ -g -o ./Redis_Rand/l3-cache ./main/L3-Cache.cpp
    ./Redis_Rand/l3-cache ./Redis_Rand/Redis_Rand.out ./Redis_Rand/Redis_Rand-cache_miss
    rm ./Redis_Rand/l3-cache
    g++ -g -o ./YCSB-A/l3-cache ./main/L3-Cache.cpp
    ./YCSB-A/l3-cache ./YCSB-A/ycsb_a.out ./YCSB-A/ycsb_a-cache_miss
    rm ./YCSB-A/l3-cache
    g++ -g -o ./YCSB-B/l3-cache ./main/L3-Cache.cpp
    ./YCSB-B/l3-cache ./YCSB-B/ycsb_b.out ./YCSB-B/ycsb_b-cache_miss
    rm ./YCSB-B/l3-cache
    mkdir Mixed_Workload
    g++ -g -o ./Mixed_Workload/l3-cache ./main/L3-Cache-Mixed_Workload.cpp
    ./Mixed_Workload/l3-cache ./Redis_Rand/Redis_Rand.out ./Facebook_ETC/Facebook_ETC.out ./Page_Rank/Page_Rank.out ./YCSB-A/ycsb_a.out ./Mixed_Workload/Mixed_Workload-cache_miss
    rm ./Mixed_Workload/l3-cache
    echo "cache miss sequence generated"

    # count the number of pages under different subpages
    echo "counting the number of pages under different subpages..."
    sed -i "5c #define SUBPAGE 0x7f" ./main/workload-PageCount.cpp
	g++ -g -o count-128 ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0xff" ./main/workload-PageCount.cpp
	g++ -g -o count-256 ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0x1ff" ./main/workload-PageCount.cpp
	g++ -g -o count-512 ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0x3ff" ./main/workload-PageCount.cpp
	g++ -g -o count-1k ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0x7ff" ./main/workload-PageCount.cpp
	g++ -g -o count-2k ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0xfff" ./main/workload-PageCount.cpp
	g++ -g -o count-4k ./main/workload-PageCount.cpp
    ./count-4k ./Linear_Regression/Linear_Regression-cache_miss ./Linear_Regression/Linear_Regression-count-4k
    ./count-512 ./Linear_Regression/Linear_Regression-cache_miss ./Linear_Regression/Linear_Regression-count-512
    ./count-4k ./YCSB-B/ycsb_b-cache_miss ./YCSB-B/ycsb_b-count-4k
    ./count-512 ./YCSB-B/ycsb_b-cache_miss ./YCSB-B/ycsb_b-count-512
    ./count-4k ./Mixed_Workload/Mixed_Workload-cache_miss ./Mixed_Workload/Mixed_Workload-count-4k
    ./count-512 ./Mixed_Workload/Mixed_Workload-cache_miss ./Mixed_Workload/Mixed_Workload-count-512
    ./count-128 ./Redis_Rand/Redis_Rand-cache_miss ./Redis_Rand/Redis_Rand-count-128
    ./count-256 ./Redis_Rand/Redis_Rand-cache_miss ./Redis_Rand/Redis_Rand-count-256
    ./count-512 ./Redis_Rand/Redis_Rand-cache_miss ./Redis_Rand/Redis_Rand-count-512
    ./count-1k ./Redis_Rand/Redis_Rand-cache_miss ./Redis_Rand/Redis_Rand-count-1k
    ./count-2k ./Redis_Rand/Redis_Rand-cache_miss ./Redis_Rand/Redis_Rand-count-2k
    ./count-4k ./Redis_Rand/Redis_Rand-cache_miss ./Redis_Rand/Redis_Rand-count-4k
    ./count-128 ./Facebook_ETC/Facebook_ETC-cache_miss ./Facebook_ETC/Facebook_ETC-count-128
    ./count-256 ./Facebook_ETC/Facebook_ETC-cache_miss ./Facebook_ETC/Facebook_ETC-count-256
    ./count-512 ./Facebook_ETC/Facebook_ETC-cache_miss ./Facebook_ETC/Facebook_ETC-count-512
    ./count-1k ./Facebook_ETC/Facebook_ETC-cache_miss ./Facebook_ETC/Facebook_ETC-count-1k
    ./count-2k ./Facebook_ETC/Facebook_ETC-cache_miss ./Facebook_ETC/Facebook_ETC-count-2k
    ./count-4k ./Facebook_ETC/Facebook_ETC-cache_miss ./Facebook_ETC/Facebook_ETC-count-4k
    ./count-128 ./Page_Rank/Page_Rank-cache_miss ./Page_Rank/Page_Rank-count-128
    ./count-256 ./Page_Rank/Page_Rank-cache_miss ./Page_Rank/Page_Rank-count-256
    ./count-512 ./Page_Rank/Page_Rank-cache_miss ./Page_Rank/Page_Rank-count-512
    ./count-1k ./Page_Rank/Page_Rank-cache_miss ./Page_Rank/Page_Rank-count-1k
    ./count-2k ./Page_Rank/Page_Rank-cache_miss ./Page_Rank/Page_Rank-count-2k
    ./count-4k ./Page_Rank/Page_Rank-cache_miss ./Page_Rank/Page_Rank-count-4k
    ./count-128 ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-128
    ./count-256 ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-256
    ./count-512 ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-512
    ./count-1k ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-1k
    ./count-2k ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-2k
    ./count-4k ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-4k
    rm count-*
    echo "counting the number of pages under different subpages finished"

    # run Facebook-ETC
    echo "run Facebook-ETC..." 
    cd Facebook_ETC
    second_line=$(sed -n '2p' Facebook_ETC-count-128)
    Facebook_ETC_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Facebook_ETC-count-256)
    Facebook_ETC_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Facebook_ETC-count-512)
    Facebook_ETC_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Facebook_ETC-count-1k)
    Facebook_ETC_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Facebook_ETC-count-2k)
    Facebook_ETC_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Facebook_ETC-count-4k)
    Facebook_ETC_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh Facebook_ETC $Facebook_ETC_4k
    ../main/run-Kona.sh Facebook_ETC $Facebook_ETC_4k
    ../main/run-Unimem.sh Facebook_ETC $Facebook_ETC_512
    ../main/run-Unimem-LRU-proportion.sh Facebook_ETC $Facebook_ETC_512
    ../main/run-Unimem-nopromote.sh Facebook_ETC $Facebook_ETC_512
    ../main/run-Unimem-set.sh Facebook_ETC $Facebook_ETC_512
    ../main/run-Unimem-subpage.sh Facebook_ETC $Facebook_ETC_128 $Facebook_ETC_256 $Facebook_ETC_512 $Facebook_ETC_1k $Facebook_ETC_2k $Facebook_ETC_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "Facebook-ETC finished" 

    # run Redis_Rand
    echo "run Redis_Rand..." 
    cd Redis_Rand
    second_line=$(sed -n '2p' Redis_Rand-count-128)
    redis_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Redis_Rand-count-256)
    redis_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Redis_Rand-count-512)
    redis_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Redis_Rand-count-1k)
    redis_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Redis_Rand-count-2k)
    redis_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Redis_Rand-count-4k)
    redis_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh Redis_Rand $redis_4k
    ../main/run-Kona.sh Redis_Rand $redis_4k
    ../main/run-Unimem.sh Redis_Rand $redis_512
    ../main/run-Unimem-LRU-proportion.sh Redis_Rand $redis_512
    ../main/run-Unimem-nopromote.sh Redis_Rand $redis_512
    ../main/run-Unimem-set.sh Redis_Rand $redis_512
    ../main/run-Unimem-subpage.sh Redis_Rand $redis_128 $redis_256 $redis_512 $redis_1k $redis_2k $redis_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "Redis_Rand finished"

    # run Page Rank
    echo "run Page Rank..." 
    cd Page_Rank
    second_line=$(sed -n '2p' Page_Rank-count-128)
    Page_Rank_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Page_Rank-count-256)
    Page_Rank_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Page_Rank-count-512)
    Page_Rank_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Page_Rank-count-1k)
    Page_Rank_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Page_Rank-count-2k)
    Page_Rank_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Page_Rank-count-4k)
    Page_Rank_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh Page_Rank $Page_Rank_4k
    ../main/run-Kona.sh Page_Rank $Page_Rank_4k
    ../main/run-Unimem.sh Page_Rank $Page_Rank_512
    ../main/run-Unimem-LRU-proportion.sh Page_Rank $Page_Rank_512
    ../main/run-Unimem-nopromote.sh Page_Rank $Page_Rank_512
    ../main/run-Unimem-set.sh Page_Rank $Page_Rank_512
    ../main/run-Unimem-subpage.sh Page_Rank $Page_Rank_128 $Page_Rank_256 $Page_Rank_512 $Page_Rank_1k $Page_Rank_2k $Page_Rank_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "Page Rank finished"

    # run YCSB-A
    echo "run YCSB-A..." 
    cd YCSB-A
    second_line=$(sed -n '2p' ycsb_a-count-128)
    ycsb_a_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-256)
    ycsb_a_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-512)
    ycsb_a_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-1k)
    ycsb_a_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-2k)
    ycsb_a_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-4k)
    ycsb_a_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh ycsb_a $ycsb_a_4k
    ../main/run-Kona.sh ycsb_a $ycsb_a_4k
    ../main/run-Unimem.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-LRU-proportion.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-nopromote.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-set.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-subpage.sh ycsb_a $ycsb_a_128 $ycsb_a_256 $ycsb_a_512 $ycsb_a_1k $ycsb_a_2k $ycsb_a_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "YCSB-A finished"

    # run Linear Regression
    echo "run Linear Regression..." 
    cd Linear_Regression
    second_line=$(sed -n '2p' Linear_Regression-count-512)
    Linear_Regression_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Linear_Regression-count-4k)
    Linear_Regression_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh Linear_Regression $Linear_Regression_4k
    ../main/run-Kona.sh Linear_Regression $Linear_Regression_4k
    ../main/run-Unimem.sh Linear_Regression $Linear_Regression_512
    ../main/run-Unimem-nopromote.sh Linear_Regression $Linear_Regression_512
    rm bip-* fifo-* lru-*
    cd ../
    echo "Linear Regression finished" 

    # run YCSB-B
    echo "run YCSB-B..." 
    cd YCSB-B
    second_line=$(sed -n '2p' ycsb_b-count-512)
    ycsb_b_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_b-count-4k)
    ycsb_b_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh ycsb_b $ycsb_b_4k
    ../main/run-Kona.sh ycsb_b $ycsb_b_4k
    ../main/run-Unimem.sh ycsb_b $ycsb_b_512
    ../main/run-Unimem-nopromote.sh ycsb_b $ycsb_b_512
    rm bip-* fifo-* lru-*
    cd ../
    echo "YCSB-B finished"

    # run mixed workload
    echo "run mixed workload..." 
    cd Mixed_Workload
    second_line=$(sed -n '2p' Mixed_Workload-count-512)
    mix_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' Mixed_Workload-count-4k)
    mix_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh Mixed_Workload $mix_4k
    ../main/run-Kona.sh Mixed_Workload $mix_4k
    ../main/run-Unimem.sh Mixed_Workload $mix_512
    rm bip-* fifo-* lru-*
    cd ../
    echo "mixed workload finished"

# Kona AMAT
Kona_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local last_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$last_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local page_fault=$(($(wc -l < $out_file) - 2))
    local hit=$(($cache_miss - $page_fault))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $write_back * $Remote_Memory_latency_4KB + $cache_miss * $Address_translation_latency) / $cache_miss" | bc)
    echo "$AMAT"
}
# Kona-PC AMAT
Kona_PC_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local last_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$last_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local page_fault=$(($(wc -l < $out_file) - 6))
    local hit=$(($cache_miss - $page_fault))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $write_back * $Remote_Memory_latency_4KB + $cache_miss * $Address_translation_latency) / $cache_miss" | bc)
    echo "$AMAT"
}
# SR&RB-4SC AMAT
SR_RB_4SC_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local last_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$last_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local page_fault=$(($(wc -l < $out_file) - 2))
    local hit=$(($cache_miss - $page_fault))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $write_back * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    echo "$AMAT"
}
# UniMem-NoPromote AMAT
UniMem_NoPromote_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local wb_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$wb_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local pf_line=$(tail -n 5 "$out_file")
    local page_fault=$(echo "$pf_line" | sed -n 's/^#page_fault:\(.*\)/\1/p')
    local ac_line=$(tail -n 4 "$out_file")
    local active_hit=$(echo "$ac_line" | sed -n 's/^#active_hit:\(.*\)/\1/p')
    local in_line=$(tail -n 3 "$out_file")
    local inactive_hit=$(echo "$in_line" | sed -n 's/^#inactive_hit:\(.*\)/\1/p')
    local hit=$(($active_hit + $inactive_hit))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_512B + $write_back * $Remote_Memory_latency_512B) / $cache_miss" | bc)
    echo "$AMAT"
}  
# UniMem AMAT
UniMem_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local wb_4k_line=$(tail -n 1 "$out_file")
    local write_back_4k=$(echo "$wb_4k_line" | sed -n 's/^#write_back_4k:\(.*\)/\1/p')
    local wb_512_line=$(tail -n 2 "$out_file")
    local write_back_512=$(echo "$wb_512_line" | sed -n 's/^#write_back_512:\(.*\)/\1/p')
    local promote_line=$(tail -n 3 "$out_file")
    local promote_num=$(echo "$promote_line" | sed -n 's/^#promote_num:\(.*\)/\1/p')
    local LRU_line=$(tail -n 4 "$out_file")
    local LRU_hit=$(echo "$LRU_line" | sed -n 's/^#LRU_hit:\(.*\)/\1/p')
    local ac_line=$(tail -n 7 "$out_file")
    local active_hit=$(echo "$ac_line" | sed -n 's/^#active_hit:\(.*\)/\1/p')
    local in_line=$(tail -n 6 "$out_file")
    local inactive_hit=$(echo "$in_line" | sed -n 's/^#inactive_hit:\(.*\)/\1/p')
    local hit=$(($active_hit + $inactive_hit))
    local pf_line=$(tail -n 9 "$out_file")
    local page_fault=$(echo "$pf_line" | sed -n 's/^#page_fault:\(.*\)/\1/p')
    local AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_512B + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_512B + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    if [[ $out_file == *1k* ]]; then
        AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_1KB + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_1KB + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    elif [[ $out_file == *2k* ]]; then
        AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_2KB + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_2KB + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    elif [[ $out_file == *4k* ]]; then
        AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_4KB + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)   
    fi
    echo "$AMAT"
}
# Data Amplification
DA(){
    local count_file=$1
    last_line=$(tail -n 1 "$count_file")
    memory_size=$(echo "$last_line" | sed -n 's/#memory_size:\(.*\)KB/\1/p')
    local out_file=$2
    if [[ $out_file == *Kona* ]]; then
        local page_fault=$(($(wc -l < $out_file) - 2))
    elif [[ $out_file == *Pagecache* ]]; then
        local page_fault=$(($(wc -l < $out_file) - 6))
    elif [[ $out_file == *nopromote* ]]; then
        local page_fault=$(($(wc -l < $out_file) - 6))    
    elif [[ $out_file == *Unimem* && $out_file != *nopromote* ]]; then
        local pf_line=$(tail -n 9 "$out_file")
        local page_fault=$(echo "$pf_line" | sed -n 's/^#page_fault:\(.*\)/\1/p')
    fi
    local page_size=$3
    local DA=$(echo "scale=2; $page_size * $page_fault / $memory_size / 1024" | bc)
    echo "$DA"
}
    
    # calculate and generate results
    # generating results of Average Memory Access Time(Section 4.2 Figure 9)
    echo "generating results of Average Memory Access Time..."
    systems=(Kona Kona-PC SR\&RB-4SC UniMem-NoPromote UniMem)
    mkdir 4.2_Average_Memory_Access_Time_Figure9
    cd 4.2_Average_Memory_Access_Time_Figure9
    echo "generating Average Memory Access Time results of Facebook-ETC"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Facebook-ETC_Figure9_a
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-100out)\t$(Kona_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-75out)\t$(Kona_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-50out)\t$(Kona_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-25out)\t$(Kona_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-10out)" >>  Facebook-ETC_Figure9_a
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Pagecache-100out)\t$(Kona_PC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Pagecache-75out)\t$(Kona_PC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Pagecache-50out)\t$(Kona_PC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Pagecache-25out)\t$(Kona_PC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Pagecache-10out)" >>  Facebook-ETC_Figure9_a
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-100out)\t$(SR_RB_4SC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-75out)\t$(SR_RB_4SC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-50out)\t$(SR_RB_4SC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-25out)\t$(SR_RB_4SC_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Kona-10out)" >>  Facebook-ETC_Figure9_a
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-nopromote-10out)" >>  Facebook-ETC_Figure9_a
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-100out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-75out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-50out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-25out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-10out)" >>  Facebook-ETC_Figure9_a
    fi
    done
    echo "generating Average Memory Access Time results of Redis-Rand"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Redis-Rand_Figure9_b
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-100out)\t$(Kona_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-75out)\t$(Kona_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-50out)\t$(Kona_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-25out)\t$(Kona_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-10out)" >>  Redis-Rand_Figure9_b
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Pagecache-100out)\t$(Kona_PC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Pagecache-75out)\t$(Kona_PC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Pagecache-50out)\t$(Kona_PC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Pagecache-25out)\t$(Kona_PC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Pagecache-10out)" >>  Redis-Rand_Figure9_b
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-100out)\t$(SR_RB_4SC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-75out)\t$(SR_RB_4SC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-50out)\t$(SR_RB_4SC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-25out)\t$(SR_RB_4SC_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Kona-10out)" >>  Redis-Rand_Figure9_b
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-nopromote-10out)" >>  Redis-Rand_Figure9_b
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-100out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-75out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-50out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-25out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-10out)" >>  Redis-Rand_Figure9_b
    fi
    done
    echo "generating Average Memory Access Time results of YCSB-A"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-A_Figure9_c
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-100out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-75out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-50out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-25out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-10out)" >>  YCSB-A_Figure9_c
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-100out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-75out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-50out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-25out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-10out)" >>  YCSB-A_Figure9_c
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-100out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-75out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-50out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-25out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-10out)" >>  YCSB-A_Figure9_c
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-10out)" >>  YCSB-A_Figure9_c
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-100out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-75out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-50out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-25out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-10out)" >>  YCSB-A_Figure9_c
    fi
    done
    echo "generating Average Memory Access Time results of YCSB-B"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-B_Figure9_d
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-100out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-75out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-50out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-25out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-10out)" >>  YCSB-B_Figure9_d
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-100out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-75out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-50out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-25out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-10out)" >>  YCSB-B_Figure9_d
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-100out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-75out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-50out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-25out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-10out)" >>  YCSB-B_Figure9_d
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-10out)" >>  YCSB-B_Figure9_d
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-100out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-75out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-50out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-25out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-10out)" >>  YCSB-B_Figure9_d
    fi
    done
    echo "generating Average Memory Access Time results of Page-Rank"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Page-Rank_Figure9_e
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-100out)\t$(Kona_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-75out)\t$(Kona_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-50out)\t$(Kona_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-25out)\t$(Kona_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-10out)" >>  Page-Rank_Figure9_e
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Pagecache-100out)\t$(Kona_PC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Pagecache-75out)\t$(Kona_PC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Pagecache-50out)\t$(Kona_PC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Pagecache-25out)\t$(Kona_PC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Pagecache-10out)" >>  Page-Rank_Figure9_e
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-100out)\t$(SR_RB_4SC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-75out)\t$(SR_RB_4SC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-50out)\t$(SR_RB_4SC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-25out)\t$(SR_RB_4SC_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Kona-10out)" >>  Page-Rank_Figure9_e
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-nopromote-10out)" >>  Page-Rank_Figure9_e
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-100out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-75out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-50out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-25out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-10out)" >>  Page-Rank_Figure9_e
    fi
    done
    echo "generating Average Memory Access Time results of Linear-Regression"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Linear-Regression_Figure9_f
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-100out)\t$(Kona_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-75out)\t$(Kona_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-50out)\t$(Kona_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-25out)\t$(Kona_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-10out)" >>  Linear-Regression_Figure9_f
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Pagecache-100out)\t$(Kona_PC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Pagecache-75out)\t$(Kona_PC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Pagecache-50out)\t$(Kona_PC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Pagecache-25out)\t$(Kona_PC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Pagecache-10out)" >>  Linear-Regression_Figure9_f
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-100out)\t$(SR_RB_4SC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-75out)\t$(SR_RB_4SC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-50out)\t$(SR_RB_4SC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-25out)\t$(SR_RB_4SC_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Kona-10out)" >>  Linear-Regression_Figure9_f
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-nopromote-10out)" >>  Linear-Regression_Figure9_f
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-100out)\t$(UniMem_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-75out)\t$(UniMem_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-50out)\t$(UniMem_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-25out)\t$(UniMem_AMAT ../Linear_Regression/Linear_Regression-cache_miss ../Linear_Regression/Linear_Regression-Unimem-10out)" >>  Linear-Regression_Figure9_f
    fi
    done
    cd ../

    # generating results of Data Amplification(Section 4.3 Figure 10)
    echo "generating results of Data Amplification..."
    systems=(Kona Kona-PC UniMem)
    mkdir 4.3_Data_Amplification_Figure10
    cd 4.3_Data_Amplification_Figure10
    echo "generating Data Amplification results of Facebook-ETC"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Facebook-ETC_Figure10_a
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Kona-100out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Kona-75out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Kona-50out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Kona-25out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Kona-10out 4096)" >>  Facebook-ETC_Figure10_a
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Pagecache-100out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Pagecache-75out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Pagecache-50out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Pagecache-25out 4096)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Pagecache-10out 4096)" >>  Facebook-ETC_Figure10_a
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-100out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-75out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-50out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-25out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-10out 512)" >>  Facebook-ETC_Figure10_a
    fi
    done
    echo "generating Data Amplification results of Redis-Rand"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Redis-Rand_Figure10_b
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Kona-100out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Kona-75out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Kona-50out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Kona-25out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Kona-10out 4096)" >>  Redis-Rand_Figure10_b
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Pagecache-100out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Pagecache-75out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Pagecache-50out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Pagecache-25out 4096)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Pagecache-10out 4096)" >>  Redis-Rand_Figure10_b
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-100out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-75out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-50out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-25out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-10out 512)" >>  Redis-Rand_Figure10_b
    fi
    done
    echo "generating Data Amplification results of YCSB-A"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-A_Figure10_c
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-100out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-75out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-50out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-25out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-10out 4096)" >>  YCSB-A_Figure10_c
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-100out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-75out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-50out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-25out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-10out 4096)" >>  YCSB-A_Figure10_c
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-100out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-75out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-50out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-25out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-10out 512)" >>  YCSB-A_Figure10_c
    fi
    done
    echo "generating Data Amplification results of YCSB-B"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-B_Figure10_d
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-100out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-75out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-50out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-25out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-10out 4096)" >>  YCSB-B_Figure10_d
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-100out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-75out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-50out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-25out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-10out 4096)" >>  YCSB-B_Figure10_d
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-100out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-75out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-50out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-25out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-10out 512)" >>  YCSB-B_Figure10_d
    fi
    done
    echo "generating Data Amplification results of Page-Rank"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Page-Rank_Figure10_e
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Kona-100out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Kona-75out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Kona-50out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Kona-25out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Kona-10out 4096)" >>  Page-Rank_Figure10_e
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Pagecache-100out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Pagecache-75out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Pagecache-50out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Pagecache-25out 4096)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Pagecache-10out 4096)" >>  Page-Rank_Figure10_e
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-100out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-75out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-50out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-25out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-10out 512)" >>  Page-Rank_Figure10_e
    fi
    done
    echo "generating Data Amplification results of Linear-Regression"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Linear-Regression_Figure10_f
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Kona-100out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Kona-75out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Kona-50out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Kona-25out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Kona-10out 4096)" >>   Linear-Regression_Figure10_f
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Pagecache-100out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Pagecache-75out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Pagecache-50out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Pagecache-25out 4096)\t$(DA ../Linear_Regression/Linear_Regression-count-4k ../Linear_Regression/Linear_Regression-Pagecache-10out 4096)" >>   Linear-Regression_Figure10_f
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Linear_Regression/Linear_Regression-count-512 ../Linear_Regression/Linear_Regression-Unimem-100out 512)\t$(DA ../Linear_Regression/Linear_Regression-count-512 ../Linear_Regression/Linear_Regression-Unimem-75out 512)\t$(DA ../Linear_Regression/Linear_Regression-count-512 ../Linear_Regression/Linear_Regression-Unimem-50out 512)\t$(DA ../Linear_Regression/Linear_Regression-count-512 ../Linear_Regression/Linear_Regression-Unimem-25out 512)\t$(DA ../Linear_Regression/Linear_Regression-count-512 ../Linear_Regression/Linear_Regression-Unimem-10out 512)" >>   Linear-Regression_Figure10_f
    fi
    done
    cd ../

    # generating results of Mixed Workload(Section 4.4 Figure 11)
    echo "generating results of Mixed Workload..."
    systems=(Kona Kona-PC UniMem)
    mkdir 4.4_Mixed_Workload_Figure11
    cd 4.4_Mixed_Workload_Figure11
    echo "generating Average Memory Access Time results of Mixed Workload"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > AMAT_Figure11_a
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Kona-100out)\t$(Kona_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Kona-75out)\t$(Kona_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Kona-50out)\t$(Kona_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Kona-25out)\t$(Kona_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Kona-10out)" >>  AMAT_Figure11_a
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Pagecache-100out)\t$(Kona_PC_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Pagecache-75out)\t$(Kona_PC_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Pagecache-50out)\t$(Kona_PC_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Pagecache-25out)\t$(Kona_PC_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Pagecache-10out)" >>  AMAT_Figure11_a
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Unimem-100out)\t$(UniMem_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Unimem-75out)\t$(UniMem_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Unimem-50out)\t$(UniMem_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Unimem-25out)\t$(UniMem_AMAT ../Mixed_Workload/Mixed_Workload-cache_miss ../Mixed_Workload/Mixed_Workload-Unimem-10out)" >>  AMAT_Figure11_a
    fi
    done
    echo "generating Data Amplification results of Mixed Workload"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > DA_Figure11_b
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Kona-100out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Kona-75out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Kona-50out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Kona-25out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Kona-10out 4096)" >>  DA_Figure11_b
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Pagecache-100out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Pagecache-75out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Pagecache-50out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Pagecache-25out 4096)\t$(DA ../Mixed_Workload/Mixed_Workload-count-4k ../Mixed_Workload/Mixed_Workload-Pagecache-10out 4096)" >>  DA_Figure11_b
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Mixed_Workload/Mixed_Workload-count-512 ../Mixed_Workload/Mixed_Workload-Unimem-100out 512)\t$(DA ../Mixed_Workload/Mixed_Workload-count-512 ../Mixed_Workload/Mixed_Workload-Unimem-75out 512)\t$(DA ../Mixed_Workload/Mixed_Workload-count-512 ../Mixed_Workload/Mixed_Workload-Unimem-50out 512)\t$(DA ../Mixed_Workload/Mixed_Workload-count-512 ../Mixed_Workload/Mixed_Workload-Unimem-25out 512)\t$(DA ../Mixed_Workload/Mixed_Workload-count-512 ../Mixed_Workload/Mixed_Workload-Unimem-10out 512)" >>  DA_Figure11_b
    fi
    done
    cd ../

    # generating results of Cache Block Size(section 4.5 Figure 12)
    echo "generating results of Cache Block Size..."
    mkdir 4.5_Cache_Block_Size_Figure12
    cd 4.5_Cache_Block_Size_Figure12
    echo "generating Average Memory Access Time results of Redis-Rand"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Redis-Rand-AMAT_Figure12_a
    echo -e "AMAT\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-subpage-512B-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-subpage-4k-10out)" >> Redis-Rand-AMAT_Figure12_a
    echo "generating Data Amplification results of Redis-Rand"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Redis-Rand-DA_Figure12_a
    echo -e "DA\t$(DA ../Redis_Rand/Redis_Rand-count-128 ../Redis_Rand/Redis_Rand-Unimem-subpage-128B-10out 128)\t$(DA ../Redis_Rand/Redis_Rand-count-256 ../Redis_Rand/Redis_Rand-Unimem-subpage-256B-10out 256)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-subpage-512B-10out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-1k ../Redis_Rand/Redis_Rand-Unimem-subpage-1k-10out 1024)\t$(DA ../Redis_Rand/Redis_Rand-count-2k ../Redis_Rand/Redis_Rand-Unimem-subpage-2k-10out 2048)\t$(DA ../Redis_Rand/Redis_Rand-count-4k ../Redis_Rand/Redis_Rand-Unimem-subpage-4k-10out 4096)" >>  Redis-Rand-DA_Figure12_a
    
    echo "generating Average Memory Access Time results of Facebook-ETC"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Facebook-ETC-AMAT_Figure12_b
    echo -e "AMAT\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-subpage-512B-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-subpage-4k-10out)" >> Facebook-ETC-AMAT_Figure12_b
    echo "generating Data Amplification results of Facebook-ETC"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Facebook-ETC-DA_Figure12_b
    echo -e "DA\t$(DA ../Facebook_ETC/Facebook_ETC-count-128 ../Facebook_ETC/Facebook_ETC-Unimem-subpage-128B-10out 128)\t$(DA ../Facebook_ETC/Facebook_ETC-count-256 ../Facebook_ETC/Facebook_ETC-Unimem-subpage-256B-10out 256)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-subpage-512B-10out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-1k ../Facebook_ETC/Facebook_ETC-Unimem-subpage-1k-10out 1024)\t$(DA ../Facebook_ETC/Facebook_ETC-count-2k ../Facebook_ETC/Facebook_ETC-Unimem-subpage-2k-10out 2048)\t$(DA ../Facebook_ETC/Facebook_ETC-count-4k ../Facebook_ETC/Facebook_ETC-Unimem-subpage-4k-10out 4096)" >>  Facebook-ETC-DA_Figure12_b

    echo "generating Average Memory Access Time results of Page-Rank"  
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Page-Rank-AMAT_Figure12_c
    echo -e "AMAT\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-subpage-512B-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-subpage-4k-10out)" >> Page-Rank-AMAT_Figure12_c
    echo "generating Data Amplification results of Page-Rank"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Page-Rank-DA_Figure12_c
    echo -e "DA\t$(DA ../Page_Rank/Page_Rank-count-128 ../Page_Rank/Page_Rank-Unimem-subpage-128B-10out 128)\t$(DA ../Page_Rank/Page_Rank-count-256 ../Page_Rank/Page_Rank-Unimem-subpage-256B-10out 256)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-subpage-512B-10out 512)\t$(DA ../Page_Rank/Page_Rank-count-1k ../Page_Rank/Page_Rank-Unimem-subpage-1k-10out 1024)\t$(DA ../Page_Rank/Page_Rank-count-2k ../Page_Rank/Page_Rank-Unimem-subpage-2k-10out 2048)\t$(DA ../Page_Rank/Page_Rank-count-4k ../Page_Rank/Page_Rank-Unimem-subpage-4k-10out 4096)" >>  Page-Rank-DA_Figure12_c

    echo "generating Average Memory Access Time results of YCSB-A"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > YCSB-A-AMAT_Figure12_d
    echo -e "AMAT\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-512B-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-4k-10out)" >> YCSB-A-AMAT_Figure12_d
    echo "generating Data Amplification results of YCSB-A"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > YCSB-A-DA_Figure12_d
    echo -e "DA\t$(DA ../YCSB-A/ycsb_a-count-128 ../YCSB-A/ycsb_a-Unimem-subpage-128B-10out 128)\t$(DA ../YCSB-A/ycsb_a-count-256 ../YCSB-A/ycsb_a-Unimem-subpage-256B-10out 256)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-subpage-512B-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-1k ../YCSB-A/ycsb_a-Unimem-subpage-1k-10out 1024)\t$(DA ../YCSB-A/ycsb_a-count-2k ../YCSB-A/ycsb_a-Unimem-subpage-2k-10out 2048)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Unimem-subpage-4k-10out 4096)" >>  YCSB-A-DA_Figure12_d
    cd ../

    # generating results of Host Memory Capacity(section 4.6 Figure 13)
    echo "generating results of Host Memory Capacity..."
    mkdir  4.6_Host_Memory_Capacity_Figure13
    cd 4.6_Host_Memory_Capacity_Figure13
    echo -e "host_memory_capacity\t0\t10%\t20%\t30%\t40%\t50%\t60%\t70%\t80%" > Host_Memory_Capacity-AMAT_Figure13
    echo -e "Redis-Rand\t$(UniMem_NoPromote_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-nopromote-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-9-1-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-8-2-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-7-3-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-6-4-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-5-5-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-4-6-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-3-7-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT_Figure13
    echo -e "Page-Rank\t$(UniMem_NoPromote_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-nopromote-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-9-1-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-8-2-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-7-3-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-6-4-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-5-5-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-4-6-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-3-7-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT_Figure13
    echo -e "Facebook-ETC\t$(UniMem_NoPromote_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-nopromote-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-9-1-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-8-2-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-7-3-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-6-4-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-5-5-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-4-6-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-3-7-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT_Figure13
    echo -e "YCSB-A\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-9-1-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-8-2-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-7-3-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-6-4-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-5-5-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-4-6-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-3-7-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT_Figure13
    cd ../

    # generating results of Set Associativity(section 4.7 Figure 14)
    echo "generating results of Set Associativity..."
    mkdir 4.7_Set_Associativity_Figure14
    cd 4.7_Set_Associativity_Figure14
    echo -e "Set Associativity\t1\t4\t8\t16" > Set_Associativity-AMAT_Figure14_a
    echo -e "Redis-Rand\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-4set-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-8set-10out)\t$(UniMem_AMAT ../Redis_Rand/Redis_Rand-cache_miss ../Redis_Rand/Redis_Rand-Unimem-16set-10out)" >> Set_Associativity-AMAT_Figure14_a
    echo -e "Facebook-ETC\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-4set-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-8set-10out)\t$(UniMem_AMAT ../Facebook_ETC/Facebook_ETC-cache_miss ../Facebook_ETC/Facebook_ETC-Unimem-16set-10out)" >> Set_Associativity-AMAT_Figure14_a
    echo -e "Page-Rank\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-4set-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-8set-10out)\t$(UniMem_AMAT ../Page_Rank/Page_Rank-cache_miss ../Page_Rank/Page_Rank-Unimem-16set-10out)" >> Set_Associativity-AMAT_Figure14_a
    echo -e "YCSB-A\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-4set-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-8set-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-16set-10out)" >> Set_Associativity-AMAT_Figure14_a

    echo -e "Set Associativity\t1\t4\t8\t16" > Set_Associativity-DA_Figure14_b
    echo -e "Redis-Rand\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-10out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-4set-10out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-8set-10out 512)\t$(DA ../Redis_Rand/Redis_Rand-count-512 ../Redis_Rand/Redis_Rand-Unimem-16set-10out 512)" >>  Set_Associativity-DA_Figure14_b
    echo -e "Facebook-ETC\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-10out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-4set-10out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-8set-10out 512)\t$(DA ../Facebook_ETC/Facebook_ETC-count-512 ../Facebook_ETC/Facebook_ETC-Unimem-16set-10out 512)" >>  Set_Associativity-DA_Figure14_b
    echo -e "Page-Rank\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-10out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-4set-10out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-8set-10out 512)\t$(DA ../Page_Rank/Page_Rank-count-512 ../Page_Rank/Page_Rank-Unimem-16set-10out 512)" >>  Set_Associativity-DA_Figure14_b
    echo -e "YCSB-A\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-4set-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-8set-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-16set-10out 512)" >>  Set_Associativity-DA_Figure14_b
    cd ../

    echo "run finished..."
    
