# Architecture

## Planned Architecture

```text
                    Internet / Client
                           |
                           v
                     API Gateway
                           |
                           v
                    Producer Lambda
                           |
                           v
                       SQS Queue
                           |
                           v
                    Worker Lambda
                      /    |     \
                     /     |      \
                    v      v       v
               DynamoDB    S3     SNS
                 status   data   notify

SQS retry exhaustion
        |
        v
       DLQ

All components
     |
     v
CloudWatch Logs / Metrics / Alarms
```

## Why This Architecture

The queue separates request intake from processing. API Gateway and the producer path can accept requests quickly while SQS absorbs traffic bursts. Lambda workers scale from queued demand instead of requiring pre-provisioned servers.

Think of SQS as a warehouse receiving dock. Trucks can keep dropping packages even when workers are busy. Lambda represents workers who pick jobs from the queue as capacity becomes available.

## Component Responsibilities

### API Gateway

Public API entry point. Valid requests should be accepted without waiting for long-running processing to finish.

### Producer Lambda

Validates and normalizes the request, creates a job ID, optionally records an initial job state, and publishes work to SQS.

### SQS

Durable buffer between request intake and processing. It protects the worker tier from sudden traffic bursts and enables retries.

### Worker Lambda

Consumes queued jobs and performs the business operation. It updates job status and writes results.

### DynamoDB

Stores job metadata and status such as `QUEUED`, `PROCESSING`, `SUCCEEDED`, and `FAILED`.

### S3

Stores uploaded objects or generated output when the workload includes files.

### SNS

Publishes success/failure notifications where useful.

### Dead-Letter Queue

Receives messages that repeatedly fail processing so poison jobs do not block normal work indefinitely.

### CloudWatch

Provides logs, metrics, dashboards, and alarms for operational visibility.

## Security Model

```text
Client
  |
  v
API Gateway
  |
  v
Lambda execution roles
  |
  +--> only required SQS actions
  +--> only required DynamoDB actions
  +--> only required S3 actions
  +--> only required SNS actions
```

IAM policies should follow least privilege. Static AWS keys must not be embedded in Lambda code or committed to the repository.

## Reliability Principles

- Durable queue before asynchronous processing.
- Explicit retry behavior.
- DLQ for repeated failures.
- Idempotent processing where possible.
- Persisted job status for observability.
- CloudWatch visibility for runtime diagnosis.

## Scaling Model

There is no fixed EC2 fleet. Lambda concurrency grows with available queued work within configured service/account limits.

```text
Low traffic  -> few/no active workers
Burst        -> queue grows -> more Lambda concurrency
Demand falls -> workers disappear automatically
```

## Planned Production Enhancements

These are enhancements, not claims of implementation:

- API authentication/authorization with Cognito or another identity provider.
- AWS WAF in front of API Gateway where Internet exposure requires it.
- KMS customer-managed keys for stricter encryption/key controls.
- Reserved concurrency and throttling tuned from measured workload behavior.
- Step Functions if the business workflow becomes multi-stage or requires orchestration.
- Infrastructure as Code after the architecture is manually understood and verified.
