.DEFAULT_GOAL := help

include .env.local

COMPOSE_FILE    ?= compose.yaml
DOCKER_COMPOSE  ?= docker compose -f $(COMPOSE_FILE)
PIP             ?= pip
PYTHON          ?= python

COLOR_SUPPORT   ?= $(shell [ "$$(tput colors 2>/dev/null)" -ge 8 ] && echo 1 || echo 0)
COLOR_GREEN      =
COLOR_YELLOW     =
COLOR_END        =
ifeq ($(COLOR_SUPPORT),1)
	COLOR_GREEN  = \033[0;32m
	COLOR_YELLOW = \033[0;33m
	COLOR_END    = \033[0m
endif

.PHONY: help install start docker-shell docker-start docker-stop

help:
	@echo "$(COLOR_YELLOW)Usage:$(COLOR_END)"
	@echo "  make [target]"
	@echo ""
	@echo "$(COLOR_YELLOW)Available targets:$(COLOR_END)"
	@echo "$(COLOR_GREEN)  install     $(COLOR_END) Installs dependencies from requirements.txt"
	@echo "$(COLOR_GREEN)  start       $(COLOR_END) Starts the web server"
	@echo "$(COLOR_YELLOW) docker$(COLOR_END)"
	@echo "$(COLOR_GREEN)  docker-start$(COLOR_END) Starts docker container"
	@echo "$(COLOR_GREEN)  docker-stop $(COLOR_END) Stops docker container"
	@echo "$(COLOR_GREEN)  docker-shell$(COLOR_END) Opens a shell in docker container"

install:
	$(PIP) install -r requirements.txt

start:
	$(PYTHON) -m dapytains.app.app

docker-shell: docker-start
	$(DOCKER_COMPOSE) exec app zsh

docker-start:
	$(DOCKER_COMPOSE) up -d

docker-stop:
	$(DOCKER_COMPOSE) down

.env.local:
	if [ ! -f .env.local ]; then cat .env > .env.local; fi
