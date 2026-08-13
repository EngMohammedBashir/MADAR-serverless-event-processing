# AWS Serverless Event-Driven Application

A portfolio project that solves a realistic company problem: processing bursty asynchronous workloads reliably without keeping servers running all day.

## Business Problem

A company receives unpredictable spikes of customer jobs such as document uploads, order-processing requests, or background tasks. During quiet periods, traffic is low. During promotions, month-end processing, or batch uploads, thousands of requests can arrive in a short period.

A tightly coupled synchronous backend can become overloaded, cause timeouts, lose work, or require expensive always-on capacity sized for peak traffic.

## Proposed Solution

Build a serverless, event-driven processing platform on AWS.

```text
Client
  |
  v
API Gateway / S3
  |
  v
SQS Queue
  |
  v
Lambda Workers
  |
  +--> DynamoDB for job state
  +--> S3 for files/results
  +--> SNS for notifications
  |
  v
CloudWatch Logs / Metrics / Alarms

Failed processing
  |
  v
SQS Dead-Letter Queue
```

## What This Project Will Demonstrate

- Serverless architecture
- Event-driven design
- Asynchronous processing
- Decoupling with SQS
- Automatic scaling with Lambda
- Retry handling and Dead-Letter Queues
- Job status persistence with DynamoDB
- File/object storage with S3
- Notifications with SNS
- Least-privilege IAM
- CloudWatch logging, metrics, and alarms
- Failure testing and recovery verification
- Cost-aware cleanup

## Primary AWS Services

- Amazon API Gateway
- AWS Lambda
- Amazon SQS
- Amazon DynamoDB
- Amazon S3
- Amazon SNS
- Amazon CloudWatch
- AWS IAM

## Project Rule

This repository distinguishes between **Planned**, **Configured**, and **Verified**. No feature is marked complete until its runtime behavior has actually been tested.

## Documentation

- [`docs/business-problem.md`](docs/business-problem.md)
- [`docs/architecture.md`](docs/architecture.md)
- [`docs/implementation-checklist.md`](docs/implementation-checklist.md)
- [`docs/progress.md`](docs/progress.md)
- [`docs/testing-verification.md`](docs/testing-verification.md)
- [`docs/security.md`](docs/security.md)
- [`docs/cost-cleanup.md`](docs/cost-cleanup.md)
- [`docs/lessons-learned.md`](docs/lessons-learned.md)

## Current Status

**Planning complete — implementation has not started yet.**
