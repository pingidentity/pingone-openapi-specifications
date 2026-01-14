.PHONY: build run templates help

# Image configuration
IMAGE ?= ping-sdk-openapi-generator:dev

# Required parameters (no defaults)
INPUT_OAS ?=
LANGUAGE ?=
VERSION ?=

# Optional parameters
PRODUCT ?= pingone
TARGET_DIR ?=

# Internal - computed target directory with default pattern
_TARGET_DIR = $(if $(TARGET_DIR),$(TARGET_DIR),dist/$(LANGUAGE)/$(PRODUCT)/$(VERSION))

help:
	@echo "SDK Generator Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  build       Build the Docker image"
	@echo "  run         Generate SDK using the Docker image"
	@echo "  templates   Pull default templates for a language"
	@echo "  help        Show this help message"
	@echo ""
	@echo "Build Parameters:"
	@echo "  IMAGE       Docker image name (default: ping-sdk-openapi-generator:dev)"
	@echo ""
	@echo "Run Parameters (required):"
	@echo "  INPUT_OAS   Path to OpenAPI specification file (required)"
	@echo "  LANGUAGE    SDK language (required, e.g., go, python)"
	echo "  VERSION     SDK version (required, e.g., v0.0.1)"
	echo ""
	echo "Run Parameters (optional):"
	echo "  PRODUCT     Product code (default: pingone, e.g., identitycloud)"
	@echo "  TARGET_DIR  Output directory (default: dist/{language}/{product}/{version})"
	@echo "  IMAGE       Docker image name (default: ping-sdk-openapi-generator:dev)"
	@echo ""
	@echo "Templates Parameters (required):"
	@echo "  LANGUAGE    SDK language (required, e.g., go, python)"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make build IMAGE=my-generator:latest"
	echo "  make run INPUT_OAS=/path/to/openapi.yaml LANGUAGE=go VERSION=v0.0.1"
	@echo "  make run INPUT_OAS=/path/to/openapi.yaml LANGUAGE=python PRODUCT=identitycloud VERSION=v1.0.0 TARGET_DIR=/custom/output"
	@echo "  make templates LANGUAGE=go"

build:
	docker build -t $(IMAGE) -f generator/sdk/Dockerfile .

run: build
	@if [ -z "$(INPUT_OAS)" ]; then \
		echo "Error: INPUT_OAS is required"; \
		echo "Usage: make run INPUT_OAS=/path/to/spec.yaml LANGUAGE=go PRODUCT=pingone VERSION=v0.0.1"; \
		exit 1; \
	fi
	@if [ -z "$(LANGUAGE)" ]; then \
		echo "Error: LANGUAGE is required"; \
		echo "Usage: make run INPUT_OAS=/path/to/spec.yaml LANGUAGE=go VERSION=v0.0.1"; \
		exit 1; \
	fi
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required"; \
		echo "Usage: make run INPUT_OAS=/path/to/spec.yaml LANGUAGE=go VERSION=v0.0.1"; \
		exit 1; \
	fi
	@mkdir -p "$(_TARGET_DIR)"
	@ABS_PATH="$(_TARGET_DIR)"; \
	case "$$ABS_PATH" in \
		/*) ;; \
		*) ABS_PATH="$$(pwd)/$$ABS_PATH";; \
	esac; \
	docker run \
		-v "$(INPUT_OAS):/openapi.yaml" \
		-v "$$ABS_PATH:/generated" \
		$(IMAGE) \
		/openapi.yaml $(LANGUAGE) $(PRODUCT) $(VERSION)

templates: build
	@if [ -z "$(LANGUAGE)" ]; then \
		echo "Error: LANGUAGE is required"; \
		echo "Usage: make templates LANGUAGE=go"; \
		exit 1; \
	fi
	@mkdir -p dist/default_templates
	docker run \
		-v "$(shell pwd)/dist/default_templates/$(LANGUAGE):/output" \
		--entrypoint /usr/local/bin/docker-entrypoint.sh \
		$(IMAGE) \
		author template -g $(LANGUAGE) -o /output
	@echo ""
	@echo "Templates extracted successfully"
	@echo "Location: dist/default_templates/$(LANGUAGE)"
	@echo "Absolute path: $(shell pwd)/dist/default_templates/$(LANGUAGE)"
