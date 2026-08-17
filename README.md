# MADAR Cloud Transformation — Phase 2

## Serverless Event-Driven Processing on AWS

## Company Context

**MADAR (مدار)** is a fictional growing digital commerce company used as one continuous cloud-transformation case study.

Phase 1 established a resilient web foundation on AWS. As MADAR continued to grow, a new problem appeared: background jobs and bursty work should not compete with customer-facing requests or require always-on processing capacity.

Phase 2 introduces an asynchronous, serverless processing layer and validates it under normal traffic, controlled failures, and burst conditions.

### MADAR Cloud Transformation Journey

```text
Company growth
   |
   v
Phase 1: Resilient AWS web architecture
   |
   v
Background workloads grow and become bursty
   |
   v
Phase 2: Serverless event-driven processing  <-- THIS PROJECT
   |
   v
Future phases
   +--> CI/CD automation
   +--> Security and threat detection
   +--> Workforce identity / SSO
   +--> Legacy workload migration
```

The goal is not to collect AWS services. Each phase starts with an operational problem MADAR encounters, then documents the architecture, implementation, runtime behavior, limitations, and engineering decisions used to solve it.

## Project Status

**CORE IMPLEMENTATION VERIFIED — the serverless pipeline, SNS notifications, retry/DLQ behavior, burst behavior, CloudWatch alarms, IAM least privilege, S3 public-access protection, and Terraform drift check have been tested. Final cleanup and billing verification remain.**

## Business Problem

As MADAR grows, customer requests and background jobs arrive in uneven bursts. A tightly coupled synchronous backend would force request intake and job processing to scale together, increasing the chance of timeouts, lost work, and expensive always-on capacity.

MADAR therefore needs an asynchronous processing layer that can accept work quickly, buffer it safely, process it independently, retain failed jobs for investigation, and provide operational visibility.

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
CloudWatch Logs / Alarms

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
- Separate least-privilege IAM roles for producer and worker

## Verified Failure Handling

A controlled worker failure was injected specifically for testing. The same SQS message was delivered to the worker three times and failed each time with an intentional exception. After reaching `maxReceiveCount = 3`, the message was moved to `madar-processing-dlq`.

```text
SQS message
  -> Worker attempt 1 FAILED
  -> Worker attempt 2 FAILED
  -> Worker attempt 3 FAILED
  -> DLQ
```

CloudWatch Logs captured all three failed invocations, and the DLQ subsequently reported one available message. This verifies the retry and failure-isolation behavior rather than only showing that a DLQ resource exists.

The temporary failure condition was removed after the test and the normal worker implementation was redeployed.

## Burst and Scaling Test

### 30 concurrent requests

The account-level Lambda concurrency quota was `10`. During a 30-request burst, the producer attempted to scale out but CloudWatch recorded **15 throttled invocations**. Some requests therefore returned `Service Unavailable` before reaching SQS.

```text
30 concurrent requests
  -> API Gateway
  -> Producer Lambda scales out
  -> account concurrency quota reached (10)
  -> 15 producer throttles observed
```

This exposed a real capacity-planning constraint rather than an application-code failure.

### 8 concurrent requests

The same test was repeated with 8 concurrent requests. All 8 returned `Job accepted`, and the producer recorded **0 throttles** during the test window.

The key lesson is that serverless services can scale rapidly, but account-level service quotas still define practical capacity. A production deployment expecting larger bursts would request a higher Lambda concurrency quota and size controls from measured demand.

## Operational Monitoring

Two CloudWatch metric alarms are managed with Terraform:

- `madar-producer-throttles` — detects producer Lambda throttling.
- `madar-dlq-messages` — detects visible messages in the dead-letter queue.

The DLQ alarm was verified in a real **In alarm** state while the controlled failed message remained in `madar-processing-dlq`.

## Security Verification

Security controls were reviewed after functional testing:

- Producer IAM policy is scoped to the specific SQS queue and DynamoDB table required by the function.
- Worker IAM policy is scoped to the required SQS queue, DynamoDB table, S3 object path, and SNS topic.
- No broad `Resource = "*"` is used in the application IAM policies where resource-level permissions are supported.
- S3 bucket public-access blocking was verified with all four controls enabled:
  - `BlockPublicAcls = true`
  - `IgnorePublicAcls = true`
  - `BlockPublicPolicy = true`
  - `RestrictPublicBuckets = true`
- The SNS email value is supplied locally through `TF_VAR_notification_email` rather than committed to source control.

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

### Producer burst throttling and account quota

![Producer Lambda burst throttling](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/producer-lambda-burst-throttling.png)

### Eight-request burst with zero throttles

![Burst test with zero throttles](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/burst-test-8-requests-zero-throttles.png)

### CloudWatch DLQ alarm

![CloudWatch DLQ alarm](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/cloudwatch-dlq-alarm.png)

### IAM least-privilege worker policy

![IAM least privilege worker policy](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/iam-least-privilege-worker-policy.png)

### S3 public-access protection

![S3 public access block](https://raw.githubusercontent.com/EngMohammedBashir/MADAR-serverless-event-processing/main/evidence/Screenshots/s3-public-access-block.png)

## Infrastructure as Code

The AWS environment is managed with **Terraform** rather than manually creating project resources in the console.

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

A final Terraform plan returned:

```text
No changes. Your infrastructure matches the configuration.
```

This confirms that the deployed AWS environment matches the current Terraform configuration.

Terraform manages API Gateway, Lambda, SQS/DLQ, DynamoDB, S3, SNS, IAM, CloudWatch alarms, and supporting integrations. The dependency lock file is committed for reproducible provider selection, while Terraform state and generated deployment artifacts are excluded from source control.

## Primary Technologies

**AWS:** API Gateway, Lambda, SQS, DynamoDB, S3, SNS, CloudWatch, IAM  
**Infrastructure as Code:** Terraform  
**Application code:** Python 3.13  
**Source control:** Git + GitHub

## Engineering Outcomes

- Translated MADAR's growing background-workload problem into an asynchronous architecture.
- Decoupled request intake from processing with SQS.
- Verified retry and dead-letter queue behavior with an actual controlled failure.
- Persisted job state in DynamoDB and archived processed results in S3.
- Verified SNS email delivery.
- Added CloudWatch logging and operational alarms.
- Used burst testing to discover and quantify an account-level Lambda concurrency bottleneck.
- Verified least-privilege application IAM policies and S3 public-access protection.
- Managed the environment reproducibly with Terraform.
- Verified the final deployed environment has no Terraform drift.

## Remaining Work

Before Phase 2 is marked fully complete:

- Optional dedicated DLQ redrive/recovery test if additional recovery evidence is desired.
- Run `terraform destroy` when the live environment is no longer needed.
- Verify no residual AWS resources remain.
- Perform final AWS billing/cost check.

## Documentation

- [`docs/business-problem.md`](docs/business-problem.md) — business case and success criteria
- [`docs/architecture.md`](docs/architecture.md) — implemented architecture and technical reasoning
- [`docs/implementation-checklist.md`](docs/implementation-checklist.md) — build checklist
- [`docs/progress.md`](docs/progress.md) — current implementation status
- [`docs/testing-verification.md`](docs/testing-verification.md) — runtime and failure test results
- [`docs/security.md`](docs/security.md) — verified controls and remaining hardening
- [`docs/cost-cleanup.md`](docs/cost-cleanup.md) — cost guardrails and cleanup verification
- [`docs/lessons-learned.md`](docs/lessons-learned.md) — engineering findings from implementation
