# Linter and formatter configuration
# ----------------------------------

PRETTIER_FILES_PATTERN = './*.md' './*/*.md'
SHFMT_FILES_PATTERN = ./**/*.sh

# Introspection targets
# ---------------------

.PHONY: help
help: targets

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-\d]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Check, lint and format targets
# ------------------------------

.PHONY: lint
lint: ## Lint files
	npx prettier --check $(PRETTIER_FILES_PATTERN)
	shfmt -d $(SHFMT_FILES_PATTERN)
	shellcheck $(SHFMT_FILES_PATTERN)

.PHONY: format
format: ## Format source files
	npx prettier --write $(PRETTIER_FILES_PATTERN)
	shfmt -w $(SHFMT_FILES_PATTERN)
