# AWS Serverless Event-Driven Application

> **Madar Cloud Transformation — Phase 2**  
> Portfolio Project 2 — Serverless, Event-Driven Architecture + Terraform Infrastructure as Code

## Company Context

**Madar (مدار)** is a fictional growing digital commerce company used as a continuous business case across this cloud engineering portfolio.

> **Portfolio note:** Madar is fictional. The architecture, implementation, testing, troubleshooting, and evidence in this repository are real hands-on portfolio work.

## Project Status

**IN PROGRESS — core serverless pipeline, SNS email delivery, and DLQ failure handling are verified. Burst/scaling, CloudWatch alarms, security review, final architecture documentation, and cleanup remain.**

## Business Problem

Madar needs to accept bursty customer/background work without coupling request intake to processing capacity. A synchronous backend can overload, time out, or require expensive always-on capacity sized for peak demand.

The solution uses a serverless asynchronous pipeline to buffer jobs, process them independently, persist status, archive results, notify operators, and isolate repeatedly failing work.

## Implemented Architecture

```text
Client
  |
  | HTTPS POST /jobs
  v
API Gateway (HTTP API)
  |
  v
Producer Lambda
  |
  +--> DynamoDB (initial job state)
  |
  v
SQS Queue
  |
  v
Worker Lambda
  |
  +--> DynamoDB (PROCESSED state)
  +--> S3 (processed event archive)
  +--> SNS -> Email notification
  |
  v
CloudWatch Logs

Repeated processing failure
  |
  | maxReceiveCount = 3
  v
SQS Dead-Letter Queue
```

## Verified Happy Path

A real HTTPS request was submitted to `POST /jobs`. API Gateway invoked the producer Lambda and returned `Job accepted` with a generated event ID. The event was queued in SQS, consumed by the worker Lambda, updated to `PROCESSED` in DynamoDB, archived as JSON in S3, and a processing notification was delivered by SNS to a confirmed email subscription. CloudWatch recorded the worker invocation.

Verified components:

- API Gateway `POST /jobs` → Producer Lambda
- Producer Lambda → SQS
- SQS → Worker Lambda event source mapping
- Worker Lambda → DynamoDB (`PROCESSED`)
- Worker Lambda → S3 processed-event archive
- Worker Lambda → SNS → confirmed email delivery
- Worker Lambda execution visible in CloudWatch Logs
- Least-privilege application IAM permissions implemented for producer and worker

## Verified Failure Handling

A controlled worker failure was injected specifically for testing. The same SQS message was delivered to the worker three times and failed each time with an intentional exception. After reaching `maxReceiveCount = 3`, the message was moved to `madar-processing-dlq`.

This verifies the behavior, not just the configuration:

```text
SQS message
  -> Worker attempt 1 FAILED
  -> Worker attempt 2 FAILED
  -> Worker attempt 3 FAILED
  -> DLQ
```

CloudWatch Logs captured all three failed invocations, and the DLQ subsequently reported one available message.

## Runtime Evidence

### SQS → Worker Lambda

![Lambda worker SQS trigger](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/lambda-worker-sqs-trigger.png)

### DynamoDB processed event

![DynamoDB processed event](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/dynamodb-processed-event.png)

### S3 processed-event archive

![S3 processed event archive](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/s3-processed-event-archive.png)

### API Gateway POST /jobs route

![API Gateway POST jobs](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/api-gateway-post-jobs.png)

### SNS subscription confirmed

![SNS subscription confirmed](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/sns-subscription-confirmed.png)

### SNS job-processed email

![SNS job processed email](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/sns-job-processed-email.png)

### DLQ message after three failed receives

![DLQ message after three failures](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/dlq-message-after-3-failures.png)

## Infrastructure as Code

The AWS environment is managed with **Terraform** rather than manually creating the project resources in the console.

```text
Write Terraform
     |
     v
terraform fmt / validate
     |
     v
terraform plan
     |
     v
terraform apply
     |
     v
Verify runtime behavior in AWS
```

Terraform currently manages the project's API Gateway, Lambda functions, SQS/DLQ, DynamoDB, S3, SNS, IAM configuration, and supporting integrations. The dependency lock file is committed for reproducible provider selection, while Terraform state and generated deployment artifacts are excluded from source control.

## Primary Technologies

**AWS:** API Gateway, Lambda, SQS, DynamoDB, S3, SNS, CloudWatch, IAM  
**Infrastructure as Code:** Terraform  
**Application code:** Python 3.13  
**Source control:** Git + GitHub

## Repository Structure

```text
.
├── README.md
├── .gitignore
├── terraform/
│   ├── .terraform.lock.hcl
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── api_gateway.tf
│   ├── sqs.tf
│   ├── lambda.tf
│   ├── dynamodb.tf
│   ├── s3.tf
│   ├── sns.tf
│   ├── cloudwatch.tf
│   └── iam.tf
├── lambda/
│   ├── producer/handler.py
│   └── worker/handler.py
├── evidence/
│   └── Screenshots/
└── docs/
```

## Engineering Principles Demonstrated

- Asynchronous/event-driven processing
- Decoupling with SQS
- Serverless compute with Lambda
- Verified retry and dead-letter queue behavior
- Persistent job state with DynamoDB
- Result archival with S3
- SNS email notification delivery
- Infrastructure as Code with Terraform
- Least-privilege IAM
- HTTPS API entry point
- CloudWatch execution visibility
- Runtime verification rather than configuration-only claims

## Remaining Verification

Before this portfolio project is marked complete, the remaining work includes:

- Run burst/scaling tests
- Complete CloudWatch metrics/alarms verification
- Complete security review
- Update architecture with final measured behavior
- Decide whether to perform a dedicated DLQ redrive/recovery test
- Run `terraform destroy` when the lab is complete
- Verify no residual resources and perform final billing check

## Project Rules

1. The repository distinguishes between **Planned**, **Configured**, and **Verified**.
2. No feature is marked complete until its actual runtime behavior is tested.
3. No AWS secrets, access keys, tokens, or Terraform state files are committed.
4. Terraform changes are reviewed with `terraform plan` before `terraform apply`.
5. Cleanup is part of the project and must be verified after `terraform destroy`.
6. Portfolio claims describe only what was actually implemented and verified.
7. Madar is a fictional company; it is business context, not claimed employment or client work.

## Documentation

- [`docs/business-problem.md`](docs/business-problem.md) — business case and success criteria
- [`docs/architecture.md`](docs/architecture.md) — architecture and design decisions
- [`docs/implementation-checklist.md`](docs/implementation-checklist.md) — build checklist
- [`docs/progress.md`](docs/progress.md) — current implementation status
- [`docs/testing-verification.md`](docs/testing-verification.md) — runtime, failure, burst, and recovery tests
- [`docs/security.md`](docs/security.md) — IAM and application security checklist
- [`docs/cost-cleanup.md`](docs/cost-cleanup.md) — cost guardrails and cleanup verification
- [`docs/lessons-learned.md`](docs/lessons-learned.md) — engineering decisions and lessons
