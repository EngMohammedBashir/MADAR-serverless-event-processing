# Architecture

## Status

**Planned architecture — implementation not started yet.**

Terraform will be the primary provisioning method. The AWS Console will be used to inspect, understand, test, and verify the resources Terraform creates.

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

All runtime components
        |
        v
CloudWatch Logs / Metrics / Alarms
```

## Why This Architecture

The queue separates request intake from processing. API Gateway and the producer Lambda can accept work quickly while SQS absorbs bursts. Lambda workers scale from queued demand instead of requiring an always-on server fleet.

Think of SQS as a company receiving dock: trucks can keep dropping packages even if workers are temporarily busy. Lambda workers pick jobs from the queue as processing capacity becomes available.

## Component Responsibilities

### API Gateway
Public API entry point. The request should be accepted quickly without waiting for asynchronous processing to finish.

### Producer Lambda
Validates and normalizes input, creates a job ID, records the initial state, and publishes work to SQS.

### SQS Main Queue
Durable buffer between request intake and processing. It protects workers from traffic bursts and provides retry behavior.

### Worker Lambda
Consumes queued jobs, performs the demo business operation, updates job status, writes results, and publishes notifications where required.

### DynamoDB
Stores job metadata and state such as `QUEUED`, `PROCESSING`, `SUCCEEDED`, and `FAILED`.

### S3
Stores test input/output objects when the workflow requires file or result storage.

### SNS
Publishes operational or job-completion notifications where useful.

### SQS Dead-Letter Queue
Receives jobs that exhaust the configured receive attempts so poison messages remain isolated and diagnosable.

### CloudWatch
Provides Lambda logs, service metrics, alarms, and runtime evidence.

### IAM
Provides separate least-privilege execution permissions for producer and worker functions.

## Terraform Design

Terraform is part of the implemented solution from the beginning.

```text
Terraform configuration
        |
        +--> API Gateway
        +--> Lambda
        +--> SQS + DLQ
        +--> DynamoDB
        +--> S3
        +--> SNS
        +--> CloudWatch
        +--> IAM
```

Planned Terraform file separation:

```text
terraform/
├── versions.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── api_gateway.tf
├── sqs.tf
├── lambda.tf
├── dynamodb.tf
├── s3.tf
├── sns.tf
├── cloudwatch.tf
└── iam.tf
```

The first implementation will intentionally stay simple: one root module, readable resource files, variables for reusable values, and outputs for runtime endpoints/resource names. Advanced modules and remote state are future Terraform learning steps, not requirements for this project.

## Security Model

```text
Client
  |
  v
API Gateway
  |
  v
Producer Lambda role
  |
  +--> required DynamoDB actions only
  +--> required SQS actions only

SQS
  |
  v
Worker Lambda role
  |
  +--> required SQS actions only
  +--> required DynamoDB actions only
  +--> required S3 actions only
  +--> required SNS actions only
```

Static AWS credentials must never be embedded in Lambda code, Terraform files, `.tfvars`, or Git history.

## Reliability Principles

- Durable queue before asynchronous processing
- Explicit retry behavior
- DLQ for repeated failures
- Persisted job status
- Idempotent processing where practical
- Observable runtime behavior
- Measured failure and recovery tests
- Reproducible infrastructure through Terraform

## Scaling Model

There is no fixed EC2 fleet.

```text
Low traffic  -> few/no active workers
Burst        -> queue depth grows -> Lambda concurrency grows
Demand falls -> queue drains -> workers disappear automatically
```

We will record observed metrics during the burst test instead of claiming theoretical scaling results.

## Planned Production Enhancements — Not Implemented

These must remain clearly separated from implemented features:

- Cognito or another identity provider for API authentication
- AWS WAF in front of the public API where justified
- Customer-managed KMS keys where organizational requirements demand them
- Reserved Lambda concurrency/throttling based on measured production workload
- Step Functions for multi-stage orchestration
- Terraform modules and remote state for larger team environments
- CI/CD automation for Terraform validation/plan/deployment

The final architecture document will be rewritten to describe only what was actually implemented and verified.