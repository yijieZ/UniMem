#!/bin/bash
arg=$1
MAX_FILE_SIZE=$((arg * 1024 * 1024 * 1024))

    tmux new-session -d -s session1 
    tmux new-session -d -s session2
    sleep 2s

    #Generate memory access sequence of Redis
    tmux send-keys -t session1 './apps/redis/redis/src/redis-server ./apps/redis/redis/redis.conf' C-m
    sleep 2s
    pid_redis=$(pidof redis-server)
    echo "----------------redis pid="$pid_redis" workload="Redis Rand""

    tmux send-keys -t session2 './pintool/pin -pid '$pid_redis' -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so &' C-m
    tmux send-keys -t session2 'memtier_benchmark -p 6379 -t 10 -n 40000000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 &' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../src/Redis_Rand' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../src/Redis_Rand/Redis_Rand.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    sleep 20s
    while :; do
        if ! kill -0 $pid_redis 2>/dev/null; then
            echo "Redis Rand finished"
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out" 2>/dev/null)
            if [ $? -eq 0 ] && [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                echo "Redis Rand reach max file size"
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
    head -n -1 ../src/Redis_Rand/Redis_Rand.out > temp.out && mv temp.out ../src/Redis_Rand/Redis_Rand.out
