#!/bin/bash
arg=$1

    ./Page_Rank.sh $arg
    sleep 2s
    ./Linear_Regression.sh $arg
    sleep 2s
    ./Redis_Rand.sh $arg
    sleep 2s
    ./Facebook_ETC.sh $arg
    sleep 2s
    ./YCSB_A.sh $arg
    sleep 2s
    ./YCSB_B.sh $arg
    sleep 2s 
