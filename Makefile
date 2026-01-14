.PHONY: build-sdk-generator generate-sdk sdk-generator-default-templates generate-sdk-help

# Image configuration
IMAGE ?= ping-sdk-openapi-generator:dev

# Required parameters (no defaults)
INPUT_OAS ?= specification/3.1/api/sdk-generation/openapi.yaml
LANGUAGE ?=
VERSION ?=

# Optional parameters
PRODUCT ?= pingone
TARGET_DIR ?=

# Internal - computed target directory with default pattern
_TARGET_DIR = $(if $(TARGET_DIR),$(TARGET_DIR),dist/$(LANGUAGE)/$(PRODUCT)/$(VERSION))

generate-sdk-help:
	@echo "SDK Generator Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  build-sdk-generator              Build the Docker image"
	@echo "  generate-sdk                     Generate SDK using the Docker image"
	@echo "  sdk-generator-default-templates  Pull default templates for a language"
	@echo "  generate-sdk-help                Show this help message"
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
	@echo "  make build-sdk-generator"
	@echo "  make build-sdk-generator IMAGE=my-generator:latest"
	echo "  make generate-sdk INPUT_OAS=/path/to/openapi.yaml LANGUAGE=go VERSION=v0.0.1"
	@echo "  make generate-sdk INPUT_OAS=/path/to/openapi.yaml LANGUAGE=python PRODUCT=identitycloud VERSION=v1.0.0 TARGET_DIR=/custom/output"
	@echo "  make sdk-generator-default-templates LANGUAGE=go"

build-sdk-generator:
	docker build -t $(IMAGE) -f generator/sdk/Dockerfile .

generate-sdk: build-sdk-generator
	@if [ -z "$(INPUT_OAS)" ]; then \
		echo "Error: INPUT_OAS is required"; \
		echo "Usage: make generate-sdk INPUT_OAS=/path/to/spec.yaml LANGUAGE=go PRODUCT=pingone VERSION=v0.0.1"; \
		exit 1; \
	fi
	@if [ -z "$(LANGUAGE)" ]; then \
		echo "Error: LANGUAGE is required"; \
		echo "Usage: make generate-sdk INPUT_OAS=/path/to/spec.yaml LANGUAGE=go VERSION=v0.0.1"; \
		exit 1; \
	fi
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required"; \
		echo "Usage: make generate-sdk INPUT_OAS=/path/to/spec.yaml LANGUAGE=go VERSION=v0.0.1"; \
		exit 1; \
	fi
	@mkdir -p "$(_TARGET_DIR)"
	@ABS_TARGET_PATH="$(_TARGET_DIR)"; \
	case "$$ABS_TARGET_PATH" in \
		/*) ;; \
		*) ABS_TARGET_PATH="$$(pwd)/$$ABS_TARGET_PATH";; \
	esac; \
	ABS_INPUT_OAS="$(INPUT_OAS)"; \
	case "$$ABS_INPUT_OAS" in \
		/*) ;; \
		*) ABS_INPUT_OAS="$$(pwd)/$$ABS_INPUT_OAS";; \
	esac; \
	docker run \
		-v "$$ABS_INPUT_OAS:/openapi.yaml" \
		-v "$$ABS_TARGET_PATH:/generated" \
		$(IMAGE) \
		/openapi.yaml $(LANGUAGE) $(PRODUCT) $(VERSION)

sdk-generator-default-templates: build-sdk-generator
	@if [ -z "$(LANGUAGE)" ]; then \
		echo "Error: LANGUAGE is required"; \
		echo "Usage: make sdk-generator-default-templates LANGUAGE=go"; \
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
