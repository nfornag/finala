# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTOOL=$(GOCMD) tool
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOARCH=$(shell go env GOARCH)

BINARY_NAME=finala
BINARY_LINUX=$(BINARY_NAME)_linux

DOCKER=docker
DOCKER_IMAGE=finala
DOCKER_TAG=dev


all: build

build: ## Download dependecies and Build the default binary 	 
		$(GOBUILD) -o $(BINARY_NAME) -v

test: ## Run tests for the project
		$(GOTEST) -coverprofile=cover.out -short -cover -failfast ./... | tee cov.txt
		
test-html: test ## Run tests with HTML for the project
		$(GOTOOL) cover -html=cover.out

release: releasebin ## Build and release all platforms builds to nexus

releasebin: ## Create release with platforms
	@go get github.com/mitchellh/gox
	@sh -c "$(CURDIR)/build-support/build.sh ${APPLICATION_NAME}"
		
build-linux: ## Build Cross Platform Binary
		CGO_ENABLED=0 GOOS=linux GOARCH=$(GOARCH) $(GOBUILD) -o $(BINARY_NAME)_linux -v

build-osx: ## Build Mac Binary
		CGO_ENABLED=0 GOOS=darwin GOARCH=$(GOARCH) $(GOBUILD) -o $(BINARY_NAME)_osx -v

build-windows: ## Build Windows Binary
		CGO_ENABLED=0 GOOS=windows GOARCH=$(GOARCH) $(GOBUILD) -o $(BINARY_NAME)_windows -v

build-docker: ## BUild Docker image file
		$(DOCKER) build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

help: ## Show Help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
