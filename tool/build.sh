#!/bin/bash
    apt install python2 -y
    apt install python-is-python2 -y
    apt install tmux -y
    apt install memcached -y
    #download pintool
    wget https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz
    tar -xzf pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz
    mv pin-3.30-98830-g1d7b601b3-gcc-linux pintool
    rm pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz
    # copy pinatrace.cpp
    cp source/pinatrace.cpp pintool/source/tools/ManualExamples/
    cd pintool/source/tools/ManualExamples/
    make obj-intel64/pinatrace.so TARGET=intel64
    cd ../../../../

    #download YCSB
    git clone http://github.com/brianfrankcooper/YCSB.git
    cd YCSB
    apt install maven -y
    mvn -pl site.ycsb:redis-binding -am clean package
    cd ../

    #download mutilate
    git clone https://github.com/leverich/mutilate.git
    apt-get install scons libevent-dev gengetopt libzmq3-dev -y
    cd mutilate/
    cp ../source/SConstruct ./
    scons
    cd ../

    #download apps
    git clone https://github.com/project-kona/apps.git  
    cd apps/turi/
    # copy app_graph_analytic.py
    cp ../../source/app_graph_analytics.py app_graph_analytics.py
    chmod +x app_graph_analytics.py
