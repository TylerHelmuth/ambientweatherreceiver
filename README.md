> [!WARNING]
> This was vibe coded. Review carefully before relying on it. I'm running it locally and can confirm it produces data,
> but I've barely reviewed the code.

# Ambient Weather Receiver

This repository houses the **Ambient Weather Receiver**, an OpenTelemetry Collector
receiver that hosts an HTTP server to ingest metrics pushed by Ambient Weather Wi-Fi
consoles configured in "custom server" mode. It is packaged as a standalone Go module
so you can include it in a custom build of the OpenTelemetry Collector.

The component source lives in [`ambientweatherreceiver/`](./ambientweatherreceiver/).
See the [component README](./ambientweatherreceiver/README.md) for configuration,
console setup, and the metrics it emits.

The Go module path is `github.com/TylerHelmuth/ambientweatherreceiver/ambientweatherreceiver`
(the module lives in the [`ambientweatherreceiver/`](./ambientweatherreceiver/) subdirectory,
so the path repeats). Because it is a module in a subdirectory, version tags must be
prefixed with the subdirectory name, e.g. `ambientweatherreceiver/v0.1.0`.

## Quick start

This repo ships an example builder manifest ([`builder-config.yaml`](./builder-config.yaml))
and a [`Makefile`](./Makefile) that builds a Collector containing this receiver. From a
checkout:

```sh
make build      # installs the builder and compiles ./_build/otelcol-ambientweather
make run        # builds, then runs the Collector with collector-config.yaml
make clean      # removes ./_build
```

## Using this receiver in your own custom Collector build

Custom Collector distributions are assembled with the
[OpenTelemetry Collector Builder (`ocb`)](https://opentelemetry.io/docs/collector/custom-collector/).
The builder reads a YAML *manifest* listing the components to compile into the binary,
then generates and builds the Collector for you.

### 1. Install the builder

```sh
go install go.opentelemetry.io/collector/cmd/builder@latest
```

### 2. Add the receiver to your manifest

Add the module to the `receivers` list of your `builder-config.yaml`. Once a version is
published (tagged) and available from a Go proxy, no `replace` directive is needed:

```yaml
dist:
  name: otelcol-custom
  description: Custom OpenTelemetry Collector with the Ambient Weather receiver
  output_path: ./_build
  otelcol_version: 0.154.0

receivers:
  - gomod: github.com/TylerHelmuth/ambientweatherreceiver/ambientweatherreceiver v0.1.0

exporters:
  - gomod: go.opentelemetry.io/collector/exporter/debugexporter v0.154.0
```

To build against a local checkout instead of a published release, add a `replace`
pointing at the receiver directory (this is what the bundled
[`builder-config.yaml`](./builder-config.yaml) does):

```yaml
replaces:
  - github.com/TylerHelmuth/ambientweatherreceiver/ambientweatherreceiver => /path/to/this/repo/ambientweatherreceiver
```

### 3. Build the Collector

```sh
builder --config builder-config.yaml
```

The compiled binary is written to the manifest's `output_path` (`./_build` above).

### 4. Configure and run

Enable the receiver in your Collector config and wire it into a metrics pipeline (see
[`collector-config.yaml`](./collector-config.yaml) for a complete example):

```yaml
receivers:
  ambientweather:
    endpoint: 0.0.0.0:6255
    path: /data/report/
    station_name: backyard

exporters:
  debug:
    verbosity: detailed

service:
  pipelines:
    metrics:
      receivers: [ambientweather]
      exporters: [debug]
```

```sh
./_build/otelcol-custom --config collector-config.yaml
```

For the full set of configuration options, console setup steps, and the metrics this
receiver emits, see the [component README](./ambientweatherreceiver/README.md).
