# Architecture

## Status

**Implemented and runtime-verified.**

Terraform is the source of truth for infrastructure provisioning. The AWS Console and AWS CLI are used to inspect behavior, verify runtime state, and capture operational evidence.

## MADAR Phase 2 Architecture

```text
                    Internet / Client
                           |
                           | HTTPS POST /jobs
                           v
                     API Gateway
                           |
                           v
                    Producer Lambda
                      /          \
                     v            v
               DynamoDB          SQS Queue
             initial state          |
                                    v
                               Worker Lambda
                              /      |       \
                             v       v        v
                        DynamoDB     S3      SNS
                        PROCESSED  archive   email

SQS retry exhaustion
        |
        | maxReceiveCount = 3
        v
       DLQ
        |
        v
CloudWatch DLQ alarm

All runtime components
        |
        v
CloudWatch Logs / Metrics / Alarms
```

## Why This Architecture

MADAR needs to accept work quickly without forcing background processing to finish inside the original HTTP request.

SQS separates intake from processing. Think of it like a receiving dock: API Gateway and the producer can accept packages quickly, while the queue safely stores them until workers are available. The worker fleet can then scale independently from request intake.

## Component Responsibilities

### API Gateway
Provides the public HTTPS entry point with the verified route `POST /jobs`.

### Producer Lambda
Creates a unique event ID, records the initial job state in DynamoDB, and sends the job to SQS.

### SQS Main Queue
Provides durable buffering, delivery retries, and decoupling between producer and worker.

### Worker Lambda
Consumes SQS messages, updates the event status to `PROCESSED`, writes the processed payload to S3, and publishes an SNS notification.

### DynamoDB
Stores event/job state using `event_id` as the partition key.

### S3
Archives processed event payloads under the `processed/` prefix.

### SNS
Publishes processing-success notifications to a confirmed email subscription.

### SQS Dead-Letter Queue
Receives messages that fail processing repeatedly. The configured `maxReceiveCount` is `3`, and this behavior was verified with a controlled failure.

### CloudWatch
Provides execution logs, Lambda throttle metrics, and alarms for producer throttling and visible DLQ messages.

### IAM
Uses separate producer and worker roles with permissions scoped to the specific resources each function needs.

## Terraform Design

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

A single readable root module is used intentionally. Terraform inferred dependencies through resource references such as queue ARNs, role ARNs, and Lambda integration attributes.

The final `terraform plan` returned:

```text
No changes. Your infrastructure matches the configuration.
```

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
  +--> SendMessage to one SQS queue
  +--> required item operations on one DynamoDB table

SQS
  |
  v
Worker Lambda role
  |
  +--> receive/delete/attributes on one SQS queue
  +--> required item operations on one DynamoDB table
  +--> object access to one S3 bucket path
  +--> Publish to one SNS topic
```

S3 Block Public Access is enabled across all four bucket-level controls. Terraform state, local provider data, generated ZIP packages, and secret variable files are excluded from GitHub.

## Reliability Model

- Durable queue before asynchronous processing
- Explicit retry behavior
- DLQ after repeated failure
- Persisted event state
- S3 processed-result archive
- Operational notification via SNS
- CloudWatch logs and alarms
- Reproducible infrastructure through Terraform

## Observed Scaling Behavior

The system was tested rather than described only theoretically.

```text
30 concurrent requests
   -> Producer Lambda attempted to scale
   -> account concurrency quota = 10
   -> 15 throttles observed

8 concurrent requests
   -> 8/8 accepted
   -> 0 throttles observed
```

This shows that service quotas remain part of capacity planning even when the underlying architecture is serverless.

## Production Enhancements — Not Implemented

- API authentication/authorization such as Cognito or another identity provider
- AWS WAF where application-layer protection is justified
- Higher Lambda concurrency quota based on measured production traffic
- Explicit API throttling/rate controls based on business requirements
- Customer-managed KMS keys where organizational policy requires them
- Step Functions for multi-stage orchestration
- Terraform remote state and modules for larger team environments
- CI/CD automation for Terraform validation, plan, and deployment

These remain recommendations until implemented and verified.
