help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Commands

unzipPrimeirazip: ## Desconpacta o ficheiro primeira.zip
	unzip primeira.zip





execute: ## Cria o executavel do script bash e executa-o
	@chmod 755 tp02_17694.sh && ./tp02_17694.sh
