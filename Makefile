commands:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Commands
help: commands

unziprimeirazip: ## Descompacta o ficheiro primeira.zip
	unzip primeira.zip

primeirazip: ## Cria o ficheiro primeira.zip
	zip -r primeira.zip ./LEGOs

execute-script: ## Cria o executavel do script.sh e executa-o
	@chmod 755 script.sh && ./script.sh

execute-script-init: ## Cria o executavel do script-init.sh e executa-o
	@chmod 755 script-init.sh && ./script-init.sh
