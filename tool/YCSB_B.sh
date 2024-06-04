#!/bin/bash
arg=$1
MAX_FILE_SIZE=$((arg * 1024 * 1024 * 1024))

    tmux new-session -d -s session1
    tmux new-session -d -s session2
    sleep 2s

    #Generate memory access sequence of YCSB-B
    tmux send-keys -t session1 'cd YCSB/' C-m
    tmux send-keys -t session2 'cd YCSB/' C-m
    tmux send-keys -t session1 '../apps/redis/redis/src/redis-server ../apps/redis/redis/redis.conf' C-m
    sleep 2s
    pid_redis=$(pidof redis-server)
    echo "----------------redis pid="$pid_redis" workload="YCSB-B""
    # modify recordcount and operationcount in YCSB/workloads/workloadb for workingset size (200000 in our evaluation)
    sed -i "s/"recordcount=[0-9]*"/"recordcount=200000"/" ./YCSB/workloads/workloadb
    sed -i "s/"operationcount=[0-9]*"/"operationcount=200000"/" ./YCSB/workloads/workloadb
    sleep 1s
    tmux send-keys -t session2 './bin/ycsb load redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m
    tmux send-keys -t session2 '../pintool/pin -pid '$pid_redis' -t ../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so' C-m
    # A redis.clients.jedis.exceptions.JedisConnectionException: java.net.SocketTimeoutException: Read timed out error may occur.
    # When this error occurs, you may need to rerun the program several times.
    tmux send-keys -t session2 './bin/ycsb run redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../../src/YCSB-B' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../../src/YCSB-B/ycsb_b.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    sleep 30s
    while ! kill -0 $pid_redis 2>/dev/null; do
        echo "YCSB-B may finished with error,retry..."
        tmux send-keys -t session1 '../apps/redis/redis/src/redis-server ../apps/redis/redis/redis.conf' C-m
        sleep 2s
        pid_redis=$(pidof redis-server)
        echo "----------------redis pid="$pid_redis" workload="YCSB-B""
        # modify recordcount and operationcount in YCSB/workloads/workloadb for workingset size (200000 in our evaluation)
        sed -i "s/"recordcount=[0-9]*"/"recordcount=200000"/" ./YCSB/workloads/workloadb
        sed -i "s/"operationcount=[0-9]*"/"operationcount=200000"/" ./YCSB/workloads/workloadb
        sleep 1s
        tmux send-keys -t session2 './bin/ycsb load redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m
        tmux send-keys -t session2 '../pintool/pin -pid '$pid_redis' -t ../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so' C-m
        # A redis.clients.jedis.exceptions.JedisConnectionException: java.net.SocketTimeoutException: Read timed out error may occur.
        # When this error occurs, you may need to rerun the program several times.
        tmux send-keys -t session2 './bin/ycsb run redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m

        tmux send-keys -t session2 'wait' C-m
        tmux send-keys -t session2 'mkdir ../../src/YCSB-B' C-m
        tmux send-keys -t session2 'mv pinatrace.out ../../src/YCSB-B/ycsb_b.out' C-m
        tmux send-keys -t session2 'kill '$pid_redis'' C-m
        sleep 30s
        done
        
    while :; do
        if ! kill -0 $pid_redis 2>/dev/null; then
            echo "YCSB-B finished"
            break
        else
            FILE_SIZE=$(stat -c%s "./YCSB/pinatrace.out" 2>/dev/null)
            if [ $? -eq 0 ] && [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                echo "YCSB-B reach max file size"
                kill -9 $pid_redis
            fi
            sleep 1s
        fi
    done

    sleep 1s
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    head -n -1 ../src/YCSB-B/ycsb_b.out > temp.out && mv temp.out ../src/YCSB-B/ycsb_b.out
