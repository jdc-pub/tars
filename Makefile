# Fedora COSMIC Atomic as a bootable container image.
# Run `make` to list targets.

SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

TAG      ?= 44
# Switch to ghcr.io/<user>/tars once this lives on GitHub.
IMAGE    ?= localhost/tars:$(TAG)
BASE_REF ?= quay.io/fedora-ostree-desktops/cosmic-atomic:$(TAG)

.PHONY: help
help: ## List targets
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk -F':.*?## ' '{printf "  %-8s %s\n", $$1, $$2}'

.PHONY: digests
digests: ## Refresh the pin in digests.txt
	@d=$$(skopeo inspect --format '{{.Digest}}' docker://$(BASE_REF)); \
	[[ $$d =~ ^sha256:[0-9a-f]{64}$$ ]] || { echo "bad digest: '$$d'" >&2; exit 1; }; \
	{ \
	  echo "# Pinned images. Regenerate with: make digests"; \
	  echo "# Format: <ref>  <digest>"; \
	  echo; \
	  printf '%-50s %s\n' '$(BASE_REF)' "$$d"; \
	} > digests.txt.tmp && mv digests.txt.tmp digests.txt
	@cat digests.txt

.PHONY: build
build: ## Build the image into root's container storage
	@read -r ref digest < <(grep -v '^#' digests.txt | grep .); \
	sudo podman build --pull=always \
	  --build-arg BASE="$${ref%:*}@$$digest" -t $(IMAGE) .

.PHONY: deploy
deploy: ## Switch this machine to the built image (reboot to apply)
	sudo bootc switch --transport containers-storage $(IMAGE)

.PHONY: status
status: ## Show the deployment status
	@sudo bootc status
