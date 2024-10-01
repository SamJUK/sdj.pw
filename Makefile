MAKEFLAGS += --always-make
.DEFAULT_GOAL := help

dev: ## Launch the development server
	hugo server --environment development

build: ## Build the static version of the site
	hugo --gc

deploy: ## Deploy the built static version of the site
	sh ./deploy.sh

build-deploy: ## Build the static site and deploy
	$(MAKE) build
	$(MAKE) deploy

help:  ## Prints the help document
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
