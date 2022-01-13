#! /bin/bash
# 清空挂载的卷，否则可能出现节点TLS握手失败的情况
docker volume prune -f
