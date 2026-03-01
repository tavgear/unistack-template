.PHONY: help sys-init init init-back init-front build up down ps

include .env
-include .env.local
export

UID := $(shell id -u)
GID := $(shell id -g)
PROJECT_DIR := $(shell pwd)

define print_header
	@echo "============================="
	@echo "  $(PROJECT_NAME)"
	@echo "============================="
	@echo "  MODE:          $(MODE)"
	@echo "  NODE_ENV:      $(MODE_NODE_ENV)"
	@echo "  DOMAIN:        https://$(DOMAIN)"
	@echo "============================="
endef

help:
	$(call print_header)
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

sys-init:
	@[ -f .env.local ] || touch .env.local

init: sys-init init-back init-front ## Initialize project

init-back: ## Init backend
	@if [ -d "back" ]; then echo "Back already exists"; else \
		echo "START init back"; \
		echo "==============="; \
		docker run --rm -t -v "$(PROJECT_DIR):/app" -w /app --user "$(UID):$(GID)" composer:2 \
			sh -lc '\
				set -eu; \
				composer create-project symfony/skeleton:"8.0.*" back --no-interaction; \
				cd back; \
				composer config --json extra.symfony.docker false; \
				composer require symfony/orm-pack symfony/twig-bundle --no-interaction; \
				composer require symfony/maker-bundle symfony/profiler-pack --dev --no-interaction; \
			'; \
		echo "==============="; \
		echo "FINISH init back"; \
	fi

init-front: ## Init frontend
	@if [ -d "front" ]; then echo "Front already exists"; else \
		echo "START init front"; \
		echo "==============="; \
		docker run --rm -t -v "$(PROJECT_DIR):/app" -w /app --user "$(UID):$(GID)" node:24-slim \
			sh -lc '\
				set -eu; \
				npx -y create-next-app@latest front --yes; \
				cd front; \
				sed -i "s/const nextConfig: NextConfig = {/const nextConfig: NextConfig = {\\n  output: '\''standalone'\'',/" next.config.ts; \
			'; \
		echo "==============="; \
		echo "FINISH init front"; \
	fi

build:  ## Build docker compose (.env, .env.local)
	$(call print_header)
	@docker compose --env-file .env --env-file .env.local -f compose.yaml -f compose.$(MODE).yaml build

up:  ## Up docker compose (.env, .env.local)
	$(call print_header)
	@docker compose --env-file .env --env-file .env.local -f compose.yaml -f compose.$(MODE).yaml up -d

down:  ## Down docker compose (.env, .env.local)
	$(call print_header)
	@docker compose --env-file .env --env-file .env.local -f compose.yaml -f compose.$(MODE).yaml down

ps:  ## Docker processes
	$(call print_header)
	@docker ps
