all: generateCrypto deployDocker createChannel deployCC copyId deployExporter deployPrometheus generateCCP
.PHONY: all
generateCrypto:
	./network.sh generateCrypto
deployDocker:
	./network.sh deployDocker
createChannel:
	./network.sh createChannel
deployCC:
	./network.sh deployCC -ccn basic -ccp ./applications/asset-transfer-basic/chaincode-go -ccl go
copyId:
	./copy_id.sh
deployExporter:
	docker stack deploy -c ./prometheus_grafana/docker-exporter.yaml exporter

deployPrometheus:
	docker-compose -f ./prometheus_grafana/docker-compose.yaml up -d

generateCCP:
	./organizations/ccp-generate.sh
