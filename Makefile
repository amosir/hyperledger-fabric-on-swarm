.PHONY: generateCrypto deployDocker createChannel deployCC copyId
generateCrypto:
	./network.sh up generateCrypto
deployDocker:
	./network.sh up deployDocker
createChannel:
	./network.sh up createChannel
deployCC:
	./network.sh up deployCC
copyId:
	./copy_id.sh
