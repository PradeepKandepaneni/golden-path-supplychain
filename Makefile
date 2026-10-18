IMAGE ?= golden-path:local
.PHONY: help test image sbom scan sign all
help: ## Show targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-8s\033[0m %s\n",$$1,$$2}'
test: ## Unit tests
	go test ./... -v
image: ## Build the image
	docker build -t $(IMAGE) .
sbom: ## Generate an SBOM (needs syft)
	syft $(IMAGE) -o spdx-json=sbom.spdx.json && echo "wrote sbom.spdx.json"
scan: ## Scan the image, fail on High/Critical (needs grype)
	grype $(IMAGE) --fail-on high
sign: ## Keyless-sign the SBOM (needs cosign + interactive OIDC)
	cosign sign-blob --yes sbom.spdx.json --output-signature sbom.sig --output-certificate sbom.pem
all: image sbom scan ## Build, SBOM, scan
