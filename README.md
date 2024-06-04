# UniMem: Redesigning Disaggregated Memory within A Unified Local-Remote Memory Hierarchy
## 1 Instructions
UniMem is implemented in simulation. We use Intel Pin tool to gather the memory access operations of workloads and simulate their run in our system. The workloads include Facebook-ETC, Redis-Rand, YCSB-A/B, Page Rank and Linear Regression in our experiments. These instructions have been tested on a clean Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-177-generic x86_64).

Clone the repository
```
git clone https://github.com/yijieZ/UniMem-ATC-2024
cd UniMem-ATC-2024
```

## 2 Setup and Run
### 2.1 Setup
We first install the Intel Pin tool. Second, we install redis, memcached, YCSB, Mutilate (for Facebook-ETC) for running workloads. We also download the dataset (Twitter-dataset.zip) for Page Rank. Then, we run the workloads with Intel Pin to gather the memory access address and data size.

You need to execute build.sh in **root** user.

```
cd tool
./build.sh
```

Then you need to manually download the Twitter-dataset and unzip it in the tool/apps/turi/ folder.

```
cd apps/turi/
wget https://archive.org/download/asu_twitter_dataset/Twitter-dataset.zip
unzip Twitter-dataset.zip
cd ../scripts
./setup.sh
```

Now you can execute generate.sh to generate sequences of memory accesses with different workloads. You also need to execute generate.sh in **root** user.

```
cd /UniMem-ATC-2024/tool/
# The parameter limits the maximum output file size in 10 GB for each workload.
./generate.sh 10
```

#### NOTE: 

1. The "generate.sh" script would take a long time.

### 2.2 Run
First set the environment variables and then run the UniMem.

You also need to execute run.sh in **root** user.
```
cd /UniMem-ATC-2024/src/
./run.sh
```

#### NOTE: 

1. The "run.sh" script would take a long time.
2. The results will be saved in folders named after the experiment section (Section 4) in the paper.
