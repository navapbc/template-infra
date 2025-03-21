# Telemetry and Application Monitoring

## Context and Problem Statement

As part of building a scalable and reliable platform template, it’s essential to provide a standardized, flexible approach to observability. Engineering teams consuming the template will need visibility into application behavior—spanning logs, metrics, and traces—to effectively monitor, troubleshoot, and optimize their services. However, without a consistent telemetry solution baked into the template, teams are forced to either implement their own ad-hoc instrumentation or tie themselves to a specific vendor’s tooling, leading to duplicated effort, fragmented observability practices, and potential vendor lock-in. To ensure ease of use, cross-team consistency, and long-term flexibility, the platform template requires a vendor-neutral, extensible telemetry framework that integrates seamlessly with any backend the implementing team chooses.

## Considered Options

### Option 1: Opentelemetry

OpenTelemetry is an open-source, vendor-neutral framework for collecting and exporting telemetry data—logs, metrics, and traces—from cloud-native applications. Managed by the CNCF, it provides standardized APIs, SDKs, and agents to simplify observability across environments.

It acts as a bridge between your applications and monitoring platforms, allowing you to instrument once and export data to any supported backend (e.g., Datadog, New Relic, Prometheus) without vendor lock-in or rework.
 
### Option 2: Vendor-Specific Library

Many vendors (Datadog, New Relic) ship a vendor-specific library or sidecar that you can use to collect telemetry. In this option, the template would defer the decision about the monitoring system to the implementing team.

### Option 3: AWS X-Ray

AWS X-Ray is an AWS-specific tracing library and product that competes with 3rd party platforms (Datadog, New Relic, etc). You would add an AWS X-Ray sidecar, and view your tracing analytics in AWS X-Ray. Given AWS's well-known poor usability and the high bar of usability required for a monitoring platform, AWS X-Ray can't be recommended at this time. In fact, AWS recently added a managed service ([Prometheus](https://docs.aws.amazon.com/grafana/latest/userguide/prometheus-data-source.html)) that competes with X-Ray. This addition subtly admits that X-Ray isn't the best product on the market.

## Why use OpenTelemetry? 

OpenTelemetry offers several compelling advantages:

- Vendor Neutrality: You can collect telemetry data without locking yourself into a specific monitoring platform. This flexibility allows organizations to change vendors or use multiple platforms without rewriting their observability stack.

- Unified Standard: By providing a single specification for logs, metrics, and traces, OpenTelemetry reduces fragmentation in observability tooling. It simplifies the instrumentation process, especially in polyglot environments.

- Strong Ecosystem and Community Support: With contributions from major cloud providers, monitoring vendors, and end-user organizations, OpenTelemetry is rapidly evolving and widely supported.

## Who is using OpenTelemetry?

Opentelemetry has integrations for every major monitoring platform, and some platforms (Honeycomb, Grafana) go so far as to _**exclusively**_ utilize Opentelemetry as their data export mechanism.

- [Dynatrace](https://docs.dynatrace.com/docs/ingest-from/opentelemetry)
- [Honeycomb](https://www.honeycomb.io/opentelemetry)
- [New Relic](https://docs.newrelic.com/docs/opentelemetry/opentelemetry-introduction/)
- [Datadog](https://docs.datadoghq.com/opentelemetry/)
- [Splunk](https://www.splunk.com/en_us/solutions/opentelemetry.html)
- [Grafana](https://grafana.com/blog/2023/07/20/a-practical-guide-to-data-collection-with-opentelemetry-and-prometheus/)

## Similar Technologies to OpenTelemetry

These technologies have a similar marketing positioning as Opentelemetry, but do not compete with it. They are mentioned here to provide more color on the type of thing that Opentelemetry is.

### Fluent-bit

Fluent-bit is a log aggregation and forwarding platform. You run it as a sidecar next to your primary application. It collects your logs and forwards them to various places. Similar to Opentelemetry, many of the large platforms have integrations with fluent-bit and recommend you use it as the primary method of getting logs into their system. 

### Kubernetes

Kubernetes is a container deployment platform, to say the least. For people previously aware of Kubernetes, you know it fulfills a vastly different role in the stack than Opentelemetry does. But it has similarities, in that it's an open source project, managed by the Cloud Native Computing Foundation, that has many integrations with 3rd party monitoring platform providers. It operates in the same "cultural" space as Opentelemetry.

## Decision Outcome

The bulk of this document describes Opentelemetry because it was chosen as the desired option before the document was written.
