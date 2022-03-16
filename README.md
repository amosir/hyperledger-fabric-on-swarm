#! https://zhuanlan.zhihu.com/p/458412538

# 基于 docker swarm 搭建 hyperledger fabric 多节点网络

## 背景

现有的 hyperledger fabric 只提供了单机的测试网络，多个节点共享同一个主机的资源，无法满足硕士研究课题的实验要求。而网上现有的搭建多主机的教程，多是基于 hyperledger fabric 1.x 版本，版本差异大，亦不满足需求。

## 说明

1. 本项目基于 fabric-sample 提供的 test-network 进行修改,在原有基础上为每个组织拓展了两个 peer 节点
2. 证书部分目前只使用了 cryptogen 工具生成方式并移除了 CA 方式相关的脚本
3. fabric 相关的二进制文件对应的版本是 2.2.0
4. 本项目仅代表实验环境的搭建过程，旨在提供便捷的实验环境，不代表生产环境
5. 使用之前请先食用 fabric-sample 项目及 hyperledger fabric 官方文档
6. 项目地址: https://github.com/Tiansir-wg/hyperledger-fabric-on-swarm

## 文件结构

```shell
├── README.md
├── applications
├── bin
├── bootstrap.sh
├── clear_volumes.sh
├── config
├── configtx
├── copy_id.sh
├── docker
├── firewall.sh
├── network.sh
├── organizations
├── rsync.sh
├── scripts
└── swarm
```

以上文件中

1. applications 直接复制于 fabric-samples
2. bin 目录存放 fabric 相关的二进制可执行文件，版本是 2.2.0(未进行托管)
3. bootstrap.sh 用于下载 2.2.0 版本的 fabric 可执行文件及相关镜像文件
4. clear_volumes.sh 用于清理容器相关的卷，搭建网络如果失败，需要在每个节点上执行该脚本
5. config 和 configtx 都是基于 fabric-sample 中相关部分进行修改的
6. copy_id.sh 用于配置 ssh 免密登录
7. docker 该目录存放 fabric 容器运行相关的文件
8. firewall.sh 用于关闭防火墙
9. network.sh 项目的启动脚本，会调用 scripts 目录的脚本
10. organizations 存放 cryptogen 需要的配置文件以及生成的证书材料
11. rsync.sh 用于实现不同主机之间的增量复制
12. swarm 存放构建 docker swarm 集群所需的脚本文件

## 网络结构

1. 集群中一共七个节点，包括一个 swarm master 节点和六个 swarm slave 节点
2. 包括两个组织，每个组织各两个 peer 节点，一个 orderer 节点(以 raft 方式运行)和两个客户端节点
3. orderer 运行在 swarm master 节点上
4. 虚拟机资源分配情况如下:

| 集群角色     | 域名                   | 虚拟机地址    | 配置                  |
| ------------ | ---------------------- | ------------- | --------------------- |
| swarm slave  | peer0.org1.example.com | 10.245.150.86 | 1 核、2G RAM、50G HDD |
| swarm slave  | peer1.org1.example.com | 10.245.150.87 | 1 核、2G RAM、50G HDD |
| swarm slave  | peer0.org2.example.com | 10.245.150.88 | 1 核、2G RAM、50G HDD |
| swarm slave  | peer1.org2.example.com | 10.245.150.89 | 1 核、2G RAM、50G HDD |
| swarm master | orderer0.example.com   | 10.245.150.90 | 4 核、8G RAM、50G HDD |
| swarm slave  | client0.example.com    | 10.245.150.91 | 1 核、2G RAM、50G HDD |
| swarm slave  | client1.example.com    | 10.245.150.92 | 1 核、2G RAM、50G HDD |

## 使用过程

### 1.设置虚拟机

分配各类硬件资源和 IP 地址

设置域名，例如:

```shell
hostnamectl set-hostname peer0.org2.example.com
```

添加 host 设置，将上述表格中所有的域名及其 IP 地址对应上

### 2.安装软件环境

包括 docker、fabric 相关的镜像和可执行文件、go 环境等

其中 docker 环境需要在所有节点上安装，fabric 相关的镜像和可执行文件和 go 环境只需要在 orderer 节点上安装

### 3.克隆项目代码

```shell
git clone git@github.com:Tiansir-wg/hyperledger-fabric-on-swarm.git
```

将 2 中下载的二进制文件放到项目的 bin 目录下

### 4. 构建 docker swarm 集群

在 orderer 节点上，进入到 swarm 目录运行 setup-swarm-cluster.sh 脚本，将生成的 token 在其他每个节点上运行一次，以将其他节点加入到集群。然后在 orderer 节点上运行 setup-docker-network.sh 脚本，在集群之上构建一个 overlay 网络

### 5.生成证书文件

在 orderer 节点上运行以下命令

```shell
./network.sh generateCrypto
```

> 只需首次搭建网络时运行，后续如果不删除则不用重新运行

### 6. 部署 fabric 相关的容器

在 orderer 节点上运行以下命令

```shell
./network.sh deployDocker
```

以下是结果
![Image](https://pic4.zhimg.com/80/v2-78f0876c6764fdd56b1361e8c12c535d.png)

### 7.创建并加入通道

在 orderer 节点上运行以下命令

```shell
./network.sh createChannel
```

### 8.部署链码

在 orderer 节点上运行以下命令

```shell
./network.sh deployCC
```
