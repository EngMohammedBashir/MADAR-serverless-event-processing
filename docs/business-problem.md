# Business Problem and Success Criteria

## Company Scenario — MADAR (مدار)

**MADAR is a fictional growing digital commerce company used as the continuous business case across this cloud-transformation journey.**

Phase 1 addressed MADAR's fragile web architecture. As the company grows further, its platform now processes background work such as order requests, file-processing tasks, and asynchronous workflows. Traffic is uneven: quiet periods can be followed by sudden bursts during promotions or batch activity.

This repository represents **Phase 2: Reliable Asynchronous Processing**.

## Current Pain Points

A tightly coupled synchronous backend creates several risks:

- Peak traffic can overload request-processing capacity.
- Requests may time out even when work could safely finish later.
- Failed jobs can be lost without durable buffering.
- Always-on processing capacity wastes resources during idle periods.
- Intake and processing cannot scale independently.
- Troubleshooting is harder when job state and failed work are not preserved.
- Manual infrastructure changes are difficult to reproduce consistently.

## Business Requirement

MADAR needs a processing platform that can accept work quickly without forcing every job to complete inside the original HTTP request.

Incoming work must be buffered safely, processed independently, observable by operations, and isolated when repeated processing fails. The infrastructure must also be reproducible through code.

## Target Outcome

Build an event-driven serverless processing layer that:

- accepts HTTPS job submissions quickly;
- records a job/event identifier;
- buffers work in SQS;
- processes jobs asynchronously with Lambda;
- persists state in DynamoDB;
- archives processed payloads in S3;
- sends SNS notifications;
- retries transient failures and isolates repeated failures in a DLQ;
- exposes meaningful logs, metrics, and alarms;
- is provisioned and reviewed through Terraform.

## Business Flow

```text
MADAR customer submits job
        |
        v
API accepts request quickly
        |
        v
Producer records event and queues work
        |
        v
SQS stores work durably
        |
        v
Worker processes job asynchronously
        |
        +--> DynamoDB updates status
        +--> S3 archives processed payload
        +--> SNS sends notification

Repeated failure
        |
        v
Dead-Letter Queue
        |
        v
CloudWatch alarm
```

## Success Criteria

### Verified

- [x] Terraform configuration validates successfully.
- [x] Terraform creates the required AWS resources.
- [x] API Gateway accepts valid job requests.
- [x] Producer Lambda returns a generated event ID and sends work to SQS.
- [x] Worker Lambda consumes SQS messages automatically.
- [x] DynamoDB records job state and reaches `PROCESSED`.
- [x] Processed payloads are archived in S3.
- [x] SNS notification delivery is verified through a confirmed email subscription.
- [x] A deliberately failing job is retried three times.
- [x] A repeatedly failing job reaches the DLQ.
- [x] CloudWatch Logs expose successful and controlled-failure invocations.
- [x] A DLQ CloudWatch alarm is verified in an actual `ALARM` state.
- [x] Burst testing records observed scaling and throttling behavior.
- [x] IAM permissions are scoped to required resources/actions.
- [x] S3 public access is blocked.
- [x] A final Terraform plan reports `No changes`.

### Remaining

- [ ] Optional dedicated DLQ redrive/recovery test.
- [ ] `terraform destroy` removes Terraform-managed infrastructure when the live environment is no longer needed.
- [ ] AWS resource checks confirm no unexpected residual resources.
- [ ] AWS Billing/Cost checks confirm the final cost position.

## Engineering Review Goals

A technical reviewer should be able to understand:

1. What operational problem MADAR needed to solve.
2. Why asynchronous processing and SQS were selected.
3. How failures are retried and isolated.
4. How state and processed output are persisted.
5. Why Terraform is the infrastructure source of truth.
6. What was measured during success, failure, and burst tests.
7. Which security controls were actually verified.
8. What remains before the live environment is fully cleaned up.

## Non-Goals

This phase does not require Kubernetes, EC2 worker fleets, a large frontend, complex microservices, or a custom domain. It focuses on reliable asynchronous serverless processing, Infrastructure as Code, operational verification, and measured failure/scaling behavior.

## Case-Study Integrity

MADAR is fictional and provides realistic business context only. It is not presented as an employer, client, or paid engagement. The repository documents the actual implementation and verification performed for this engineering case study.
