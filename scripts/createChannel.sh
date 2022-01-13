#!/bin/bash

# imports
. scripts/envVar.sh
. scripts/utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

if [ ! -d "channel-artifacts" ]; then
    mkdir channel-artifacts
fi

createChannelTx() {
    set -x
    echo "+++++++++++++${FABRIC_CFG_PATH}"
    configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
    setGlobals 1 0
    # Poll in case the raft leader is not set yet
    local rc=1
    local COUNTER=1
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        set -x
        peer channel create -o "$ORDERER_NAME":7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock $BLOCKFILE --tls --cafile $ORDERER_CA >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    verifyResult $res "Channel creation failed"
}

# joinChannel ORG
# TODO: 需要设置每个peer节点，目前只设置了peer0
#
joinChannel() {
    FABRIC_CFG_PATH=${PWD}/config/
    ORG=$1
    PEER=$2
    setGlobals $ORG $PEER
    local rc=1
    local COUNTER=1
    ## Sometimes Join takes time, hence retry
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        set -x
        peer channel join -b $BLOCKFILE >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
    ORG=$1
    docker exec cli ./scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME
}

FABRIC_CFG_PATH=${PWD}/configtx

## 生成通道创建事务
infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTx

FABRIC_CFG_PATH=$PWD/config/
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

## 创建通道
infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

## 将所有的peer节点加入通道
infoln "Joining org1 peer 0 to the channel..."
joinChannel 1 0
infoln "Joining org1 peer 1 to the channel..."
joinChannel 1 1
infoln "Joining org2 peer 0 to the channel..."
joinChannel 2 0
infoln "Joining org2 peer 1 to the channel..."
joinChannel 2 1

## 为通道中的每个组织设置锚节点
infoln "Setting anchor peer for org1..."
setAnchorPeer 1
infoln "Setting anchor peer for org2..."
setAnchorPeer 2

successln "Channel '$CHANNEL_NAME' joined"
