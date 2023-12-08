.DEFAULT_GOAL := help

APP_DOMAIN?=mysuperapp
APP_ENDPOINT=https://$(APP_DOMAIN).wip

setup: .env.agent.local setup-domain composer-install ## configures the stack
	@echo "Do not forget to tweak your $< file with your blackfire credentials"
.PHONY: setup

.env.agent.local:
	cp $@.dist $@

composer-install:
	docker run --rm -u $(shell id -u):$(shell id -g) -w /app -v $(shell pwd):/app composer:2 install
.PHONY: composer-install

setup-domain:
	symfony server:ca:install
	symfony proxy:domain:attach $(APP_DOMAIN)
.PHONY: setup-domain

start: app-start proxy-start agent-start ## starts the whole stack
.PHONY: start

app-start:
	symfony server:start -d
.PHONY: app-start

app-stop:
	symfony server:stop
.PHONY: app-stop

proxy-start:
	symfony proxy:start
.PHONY: proxy-start

proxy-stop:
	symfony proxy:stop
.PHONY: proxy-stop

agent-start:
	docker-compose up -d
.PHONY: agent-start

agent-stop:
	docker-compose stop
.PHONY: agent-stop

stop: proxy-stop agent-stop app-stop ## stops the whole stack
.PHONY: stop

rm:
	docker-compose rm -f
.PHONY: rm

BLACKFIRE_ENV?=pleaseredefineBLACKFIRE_ENVwithyourblackfireenvuuidorname
BLACKFIRE_ENDPOINT?=https://blackfire.io
BLACKFIRE_SCENARIO?=blackfire/scenarios/simple.bkf
BLACKFIRE_PLAYER_VERSION?=2.4.1

PROXY_URL=$(shell symfony proxy:url)
BLACKFIRE_PLAYER_ENV=-e BLACKFIRE_ENDPOINT -e BLACKFIRE_CLIENT_ID -e BLACKFIRE_CLIENT_TOKEN -e HTTP_PROXY=$(PROXY_URL) -e HTTPS_PROXY=$(PROXY_URL) -e APP_ENDPOINT=$(APP_ENDPOINT)

blackfire-player: ## starts the blackfire player to trigger a build against the app
	docker run --rm $(BLACKFIRE_PLAYER_ENV) --network=host -v $(shell pwd):/app blackfire/player:$(BLACKFIRE_PLAYER_VERSION) run /app/$(BLACKFIRE_SCENARIO) --endpoint="$(APP_ENDPOINT)" --blackfire-env "$(BLACKFIRE_ENV)" --ssl-no-verify
.PHONY: blackfire-player

bkf-shell: ## starts a shell from the blackfire player docker image, for testing purpose
	docker run --rm -it $(BLACKFIRE_PLAYER_ENV) --network=host -v $(shell pwd):/app --entrypoint /bin/ash blackfire/player:$(BLACKFIRE_PLAYER_VERSION)
.PHONY: bkf-shell

clean: stop rm ## clean the stack
	symfony proxy:domain:detach $(APP_DOMAIN)
	rm -rf vendor/
.PHONY: clean

help: ## some help
	@grep -hE '(^[a-zA-Z_-]+:.*?##.*$$)|(^###)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m\n/'
.PHONY: help
