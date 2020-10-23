SHELL:=/usr/bin/env bash

TOOLS_DIR := hack/tools
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
GORELEASER_BIN := bin/goreleaser
GORELEASER := $(TOOLS_DIR)/$(GORELEASER_BIN)
GOVENDOR_BIN := bin/govendor
GOVENDOR := $(TOOLS_DIR)/$(GOVENDOR_BIN)

$(GORELEASER): $(TOOLS_DIR)/go.mod
	cd $(TOOLS_DIR) && go build -o $(GORELEASER_BIN) github.com/goreleaser/goreleaser

$(GOVENDOR): $(TOOLS_DIR)/go.mod
	cd $(TOOLS_DIR) && go build -o $(GOVENDOR_BIN) github.com/kardianos/govendor

.PHONY: install
install: $(GOVENDOR)
	./hack/govendor-sync.sh
	go install .

.PHONY: build
build: $(GOVENDOR)
	./hack/govendor-sync.sh
	go build -o dist/stern .

.PHONY: build-cross
build-cross: $(GOVENDOR) $(GORELEASER)
	$(GORELEASER) build --snapshot --rm-dist

.PHONY: archive
archive: $(GOVENDOR) $(GORELEASER)
	$(GORELEASER) release --rm-dist --skip-publish --snapshot

.PHONY: release
release: $(GOVENDOR) $(GORELEASER)
	$(GORELEASER) release --rm-dist

.PHONY: clean
clean: clean-tools clean-dist

.PHONY: clean-tools
clean-tools:
	rm -rf $(TOOLS_BIN_DIR)

.PHONY: clean-dist
clean-dist:
	rm -rf ./dist
