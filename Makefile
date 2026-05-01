# Convenience wrappers around the common `yarn` scripts defined in
# package.json. `yarn` remains the source of truth — these targets just
# spare the typing and give tab-completion to anyone who prefers `make`.
#
# Run `make help` for a list of targets.

YARN ?= yarn

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n\nTargets:\n"} \
		/^[a-zA-Z0-9_.-]+:.*##/ {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

.PHONY: install
install: ## Install workspace dependencies (yarn install).
	$(YARN) install

.PHONY: dev
dev: ## Run app + backend + fixture server concurrently.
	$(YARN) dev

.PHONY: start
start: ## Start the demo Backstage frontend only.
	$(YARN) start

.PHONY: start-backend
start-backend: ## Start the demo Backstage backend only.
	$(YARN) start-backend

.PHONY: build
build: ## Build all workspaces (backstage-cli repo build --all).
	$(YARN) build

.PHONY: tsc
tsc: ## Typecheck (incremental).
	$(YARN) tsc

.PHONY: tsc-full
tsc-full: ## Clean and typecheck from scratch (CI parity).
	$(YARN) tsc:full

.PHONY: clean
clean: ## backstage-cli repo clean.
	$(YARN) clean

.PHONY: test
test: ## Run Jest across the workspace.
	$(YARN) test

.PHONY: test-all
test-all: ## Run Jest with coverage.
	$(YARN) test:all

.PHONY: test-e2e
test-e2e: ## Run Playwright e2e tests.
	$(YARN) test:e2e

.PHONY: lint
lint: ## Lint files changed since origin/main.
	$(YARN) lint

.PHONY: lint-all
lint-all: ## Lint the entire repo.
	$(YARN) lint:all

.PHONY: lint-type-deps
lint-type-deps: ## Verify declared dependencies match actual usage.
	$(YARN) lint:type-deps

.PHONY: fix
fix: ## Auto-fix lint/format issues (backstage-cli repo fix).
	$(YARN) fix

.PHONY: prettier-check
prettier-check: ## Check formatting without writing.
	$(YARN) prettier:check

.PHONY: prettier-fix
prettier-fix: ## Rewrite files with Prettier.
	$(YARN) prettier:fix

.PHONY: lock-check
lock-check: ## Verify yarn.lock is consistent.
	$(YARN) lock:check

.PHONY: new
new: ## Scaffold a new plugin under the @ori scope.
	$(YARN) new

.PHONY: changeset
changeset: ## Create a changeset for the current changes.
	$(YARN) changeset

.PHONY: release
release: ## Run the release prep script (changeset version + reformat).
	$(YARN) release
