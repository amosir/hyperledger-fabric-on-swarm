.PHONY: generateCrypto deployDocker createChannel deployCC copyId
generateCrypto:
	./network.sh up generateCrypto
deployDocker:
	./network.sh up deployDocker
createChannel:
	./network.sh up createChannel
deployCC:
	./network.sh deployCC -ccn basic -ccp ./applications/asset-transfer-basic/chaincode-go -ccl go
copyId:
	./copy_id.sh