#! /bin/bash
# 清空挂载的卷，否则可能出现节点TLS握手失败的情况， 每次关闭服务之后需要执行一次
docker volume prune -f
