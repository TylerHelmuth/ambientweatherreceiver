# Makefile for building an example OpenTelemetry Collector that bundles the
# Ambient Weather receiver, using the OpenTelemetry Collector Builder (ocb).

# Version of the builder to install. Keep aligned with otelcol_version in the manifest.
OTELCOL_BUILDER_VERSION ?= 0.154.0
# Builder binary. Defaults to the one installed into GOPATH/bin by `install-builder`.
OTELCOL_BUILDER ?= $(shell go env GOPATH)/bin/builder
# OCB manifest describing the components to compile into the Collector.
BUILDER_CONFIG ?= builder-config.yaml
# Where the built binary lands (must match `dist.output_path` in the manifest).
OUTPUT_DIR ?= ./_build
# Collector runtime config used by `make run`.
COLLECTOR_CONFIG ?= collector-config.yaml

.PHONY: build
build: install-builder
	$(OTELCOL_BUILDER) --config $(BUILDER_CONFIG)

.PHONY: install-builder
install-builder:
	go install go.opentelemetry.io/collector/cmd/builder@v$(OTELCOL_BUILDER_VERSION)

.PHONY: run
run: build
	$(OUTPUT_DIR)/otelcol-ambientweather --config $(COLLECTOR_CONFIG)

.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)
