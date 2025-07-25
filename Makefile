.DEFAULT_GOAL := help

include .env.local

COMPOSE_FILE    ?= compose.yaml
DOCKER_COMPOSE  ?= docker compose -f $(COMPOSE_FILE)
PIP             ?= pip
PYTEST          ?= pytest
PYTHON          ?= python
SERVER_ENV      ?= prod
VERBOSE         ?= 0

COLOR_SUPPORT   ?= $(shell [ "$$(tput colors 2>/dev/null)" -ge 8 ] && echo 1 || echo 0)
COLOR_GREEN      =
COLOR_YELLOW     =
COLOR_END        =
ifeq ($(COLOR_SUPPORT),1)
	COLOR_GREEN  = \033[0;32m
	COLOR_YELLOW = \033[0;33m
	COLOR_END    = \033[0m
endif

.PHONY: help install start test docker-shell docker-start docker-stop

help:
	@echo "$(COLOR_YELLOW)Usage:$(COLOR_END)"
	@echo "  make [target] [VARIABLE=value]"
	@echo ""
	@echo "$(COLOR_YELLOW)Example:$(COLOR_END)"
	@echo "  make start VERBOSE=1"
	@echo ""
	@echo "$(COLOR_YELLOW)Available targets:$(COLOR_END)"
	@echo "$(COLOR_GREEN)  install     $(COLOR_END) Installs dependencies from requirements.txt"
	@echo "$(COLOR_GREEN)  start       $(COLOR_END) Starts the web server"
	@echo "$(COLOR_GREEN)  test        $(COLOR_END) Executes tests"
	@echo "$(COLOR_YELLOW) docker$(COLOR_END)"
	@echo "$(COLOR_GREEN)  docker-start$(COLOR_END) Starts docker container"
	@echo "$(COLOR_GREEN)  docker-stop $(COLOR_END) Stops docker container"
	@echo "$(COLOR_GREEN)  docker-shell$(COLOR_END) Opens a shell in docker container"

install:
	$(PIP) install -r requirements.txt
ifneq ($(SERVER_ENV),"prod")
	$(PIP) install -r requirements-dev.txt
endif

start:
ifeq ($(VERBOSE),1)
	$(MAKE) install
else
	@$(MAKE) install > /dev/null
endif
	$(PYTHON) -m dapytains.app.app

test:
ifeq ($(VERBOSE),1)
	$(MAKE) install
else
	@$(MAKE) install > /dev/null
endif
ifeq ($(SERVER_ENV),"prod")
	$(error "Tests cannot run in 'prod' environment")
else
	$(PYTEST) --doctest-modules --cov=dapytains --verbose
endif

docker-shell: docker-start
	$(DOCKER_COMPOSE) exec app zsh

docker-start:
	$(DOCKER_COMPOSE) up -d --build --remove-orphans

docker-stop:
	$(DOCKER_COMPOSE) down

.env.local:
	if [ ! -f .env.local ]; then cat .env > .env.local; fi
