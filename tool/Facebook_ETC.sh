#!/bin/bash
arg=$1
MAX_FILE_SIZE=$((arg * 1024 * 1024 * 1024))

    tmux new-session -d -s session1 
    tmux new-session -d -s session2
    sleep 2s

    #Generate memory access sequence of Facebook-ETC
    tmux send-keys -t session1 'memcached -m 20480 -u root' C-m
    sleep 2s
    pid_memcached=$(pidof memcached | cut -d' ' -f1)
    echo "----------------memcached="$pid_memcached" workload="Facebook-ETC""

    tmux send-keys -t session2 './pintool/pin -pid '$pid_memcached' -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so &' C-m
    tmux send-keys -t session2 './mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 50000000000 -u 1 &' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../src/Facebook_ETC' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../src/Facebook_ETC/Facebook_ETC.out' C-m
    tmux send-keys -t session2 'kill '$pid_memcached'' C-m
    sleep 20s
    while :; do
        if ! kill -0 $pid_memcached 2>/dev/null; then
            echo "Facebook-ETC finished"
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out" 2>/dev/null)
            if [ $? -eq 0 ] && [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_memcached
                sleep 1s
                if ! kill -0 $pid_memcached 2>/dev/null; then
                    kill -9 $(pidof mutilate | cut -d' ' -f1)
                    echo "Facebook-ETC reach max file size"
                    break
                fi
            fi
            sleep 1s
        fi
    done

    sleep 1s
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    kill $(pidof memcached | cut -d' ' -f1)
    head -n -1 ../src/Facebook_ETC/Facebook_ETC.out > temp.out && mv temp.out ../src/Facebook_ETC/Facebook_ETC.out
