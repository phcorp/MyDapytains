.DEFAULT_GOAL := help

include .env.local

COMPOSE_FILE   ?= compose.yaml
DOCKER_COMPOSE ?= docker compose -f $(COMPOSE_FILE)
PIP            ?= pip
PYTHON         ?= python

.PHONY: help install start docker-start docker-stop

help: ## display this help
	@grep -E '(^[a-zA-Z_-]+:.*?## .*$$)|(^##)' $(MAKEFILE_LIST) | sed -e "s/^[^:]*://g" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[36m##/[33m/'

install: ## install dependencies
	$(PIP) install -r requirements.txt

start: ## start the web server
	$(PYTHON) -m dapytains.app.app

docker-shell: docker-start ## open a shell in docker container
	$(DOCKER_COMPOSE) exec app zsh

docker-start: ## start docker container
	$(DOCKER_COMPOSE) up -d

docker-stop: ## stop docker container
	$(DOCKER_COMPOSE) down

.env.local:
	if [ ! -f .env.local ]; then cat .env > .env.local; fi
