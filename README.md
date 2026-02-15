# Fluent Logging

This repository provides configurations and examples for implementing a robust logging architecture using Fluent Bit and Fluentd. These tools are essential components in a unified logging layer, enabling efficient collection, processing, and forwarding of log data.

## Fluent Bit

Fluent Bit is a lightweight, high-performance, and extensible log processor, metrics collector, and forwarder. It is designed to be highly efficient, making it ideal for resource-constrained environments like embedded systems or containerized setups.

**Key Characteristics and Use Cases:**
*   **Edge Log Processing**: Collects logs directly from applications, files, or system services at the source.
*   **Resource Efficiency**: Minimal CPU and memory footprint, suitable for sidecar deployments in container orchestration platforms like AWS ECS with FireLens.
*   **Parsing and Filtering**: Capable of parsing various log formats (e.g., JSON) and filtering logs before forwarding.
*   **Output to Diverse Destinations**: Supports a wide range of output plugins, including cloud services like AWS Kinesis Firehose, Kafka, Elasticsearch, and other Fluentd instances.
*   **Metrics**: Can expose internal metrics for monitoring.

**Configuration Examples (See `fluentbit/`):**
*   `fluentbit.conf`: Main configuration, detailing input (e.g., tailing `/var/log/app/orders.log`), parsing, and output (e.g., to Kinesis Firehose).
*   `parsers.conf`: Defines custom log parsers, such as for JSON formatted logs.
*   `ecs-taskdef-sample.json`: An AWS ECS task definition showcasing Fluent Bit as a sidecar container using FireLens for log routing.

## Fluentd

Fluentd is an open-source data collector for a unified logging layer. It's more feature-rich and generally used for more complex log aggregation, routing, and transformation tasks, often acting as a central logging hub.

**Key Characteristics and Use Cases:**
*   **Centralized Log Aggregation**: Collects logs from various sources, including other Fluent Bit instances, and consolidates them.
*   **Robust Filtering and Routing**: Offers advanced capabilities for filtering, buffering, and routing log data to multiple destinations based on tags and content.
*   **Flexible Output**: Supports a vast ecosystem of plugins for outputting to databases, analytics platforms, storage systems, and more.
*   **Transformation**: Can modify and enrich log records before forwarding.

**Configuration Examples (See `fluentd/`):**
*   `fluent.conf`: A basic configuration demonstrating tailing logs and forwarding them, potentially for stream processing (e.g., to Norikra).
*   `receiver.conf`: Configures Fluentd to act as a log receiver, listening on a port (e.g., 24224) for incoming logs and writing them to a file.
*   `sender.conf`: Configures Fluentd to act as a log sender, tailing logs (e.g., Apache access logs) and forwarding them to a remote Fluentd receiver.

## Directory Structure:

-   `fluentbit/`: Contains configuration files and examples for setting up and deploying **Fluent Bit** for efficient log collection and forwarding, especially in containerized environments.
-   `fluentd/`: Contains configuration files and examples for configuring **Fluentd** for centralized log aggregation, routing, and processing.