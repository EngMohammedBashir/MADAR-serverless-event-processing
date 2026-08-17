# Architecture

## Status

**Implemented, runtime-verified, recovered through DLQ redrive, and torn down after validation.**

Terraform remains the source of truth for infrastructure definition. The live AWS resources were removed after testing, while the code remains available to recreate the environment.

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
        +--> CloudWatch DLQ alarm
        |
        +--> redrive to source queue after failure correction

All runtime components
        |
        v
CloudWatch Logs / Metrics / Alarms
```

## Why This Architecture

MADAR needed to accept work quickly without forcing background processing to finish inside the original HTTP request.

SQS separates intake from processing. Think of it like a receiving dock: API Gateway and the producer can accept packages quickly, while the queue safely stores them until workers are available. The worker can then process queued demand independently from request intake.

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
Archives processed event payloads under the `processed/` prefix. Versioning was enabled and later became an important cleanup consideration because existing object versions prevented bucket deletion until they were explicitly removed.

### SNS
Publishes processing-success notifications to a confirmed email subscription.

### SQS Dead-Letter Queue
Receives messages that fail processing repeatedly. The configured `maxReceiveCount` was `3`, and this behavior was verified with a controlled failure.

The DLQ was also used for recovery validation: after the temporary failure condition was removed, the failed message was redriven to the source queue and successfully processed.

### CloudWatch
Provided execution logs, Lambda throttle metrics, and alarms for producer throttling and visible DLQ messages.

### IAM
Used separate producer and worker roles with permissions scoped to named MADAR resources. The final Terraform source tightens action lists to the operations used by the current handlers.

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

A single readable root module is used intentionally. Terraform infers dependencies through resource references such as queue ARNs, role ARNs, Lambda integration attributes, and environment-variable values.

Before teardown, the final `terraform plan` returned:

```text
No changes. Your infrastructure matches the configuration.
```

After teardown, a normal plan showed the full stack would be created again, demonstrating that the environment is reproducible even though the live resources were removed.

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
  +--> PutItem on one DynamoDB table

SQS
  |
  v
Worker Lambda role
  |
  +--> receive/delete/attributes on one SQS queue
  +--> UpdateItem on one DynamoDB table
  +--> PutObject under one S3 bucket path
  +--> Publish to one SNS topic
```

S3 Block Public Access was enabled across all four bucket-level controls. Terraform state, local provider data, generated ZIP packages, and secret variable files are excluded from GitHub.

The HTTP API was intentionally unauthenticated during controlled testing. Authentication and stronger request controls remain production hardening items.

## Reliability Model

- Durable queue before asynchronous processing
- Explicit retry behavior
- DLQ after repeated failure
- Persisted event state
- S3 processed-result archive
- Operational notification via SNS
- CloudWatch logs and alarms
- Safe redrive/recovery after failure correction
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

## Verified Failure and Recovery Behavior

```text
Controlled failing event
   -> Worker fails
   -> retry 1
   -> retry 2
   -> retry 3
   -> DLQ
   -> operational alarm
   -> failure condition removed
   -> DLQ redrive
   -> Worker succeeds
   -> same event = PROCESSED
```

## Lifecycle and Cleanup Behavior

```text
Live validation environment
   -> terraform plan -destroy
   -> terraform destroy
   -> versioned S3 data blocks bucket removal
   -> delete object versions
   -> terraform destroy
   -> Terraform-managed environment removed
```

The architecture therefore includes not only deployment and runtime behavior, but also an observed teardown path and data-lifecycle lesson.

## Production Enhancements — Not Implemented

- API authentication/authorization such as Cognito or another identity provider
- AWS WAF where application-layer protection is justified
- Higher Lambda concurrency quota based on measured production traffic
- Explicit API throttling/rate controls based on business requirements
- Strong request schema validation and graceful malformed-input handling
- Idempotency controls for at-least-once SQS delivery
- More robust state transitions so `PROCESSED` is written only after required downstream side effects succeed
- Transactional/outbox handling for the producer's DynamoDB-write/SQS-send boundary
- Customer-managed KMS keys where organizational policy requires them
- Explicit Terraform management of Lambda CloudWatch log groups and retention
- Step Functions for multi-stage orchestration where appropriate
- Terraform remote state and modules for larger team environments
- CI/CD automation for Terraform validation, plan, and deployment

These remain recommendations until implemented and verified.
