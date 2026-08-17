# Business Problem and Success Criteria

## Company Scenario — MADAR (مدار)

**MADAR is a fictional growing digital commerce company used as the continuous business case across this cloud-transformation journey.**

Phase 1 addressed MADAR's fragile web architecture. As the company grew further, its platform began processing more background work such as order requests, file-processing tasks, and asynchronous workflows. Traffic was uneven: quiet periods could be followed by sudden bursts during promotions or batch activity.

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

MADAR needed a processing platform that could accept work quickly without forcing every job to complete inside the original HTTP request.

Incoming work needed to be buffered safely, processed independently, observable by operations, isolated after repeated failure, recoverable through replay, and reproducible through Infrastructure as Code.

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
- supports safe recovery/redrive after the failure condition is corrected;
- exposes meaningful logs, metrics, and alarms;
- is provisioned and reviewed through Terraform;
- can be torn down cleanly after verification.

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
        +--> CloudWatch alarm
        |
        v
Failure corrected
        |
        v
DLQ redrive
        |
        v
Recovered processing
```

## Success Criteria

### Verified

- [x] Terraform configuration validated successfully.
- [x] Terraform created the required AWS resources.
- [x] API Gateway accepted valid job requests.
- [x] Producer Lambda returned a generated event ID and sent work to SQS.
- [x] Worker Lambda consumed SQS messages automatically.
- [x] DynamoDB recorded job state and reached `PROCESSED`.
- [x] Processed payloads were archived in S3.
- [x] SNS notification delivery was verified through a confirmed email subscription.
- [x] A deliberately failing job was retried three times.
- [x] A repeatedly failing job reached the DLQ.
- [x] CloudWatch Logs exposed successful and controlled-failure invocations.
- [x] A DLQ CloudWatch alarm was verified in an actual `ALARM` state.
- [x] The failed DLQ message was redriven successfully.
- [x] The same failed event was later verified as `PROCESSED`.
- [x] Burst testing recorded observed scaling and throttling behavior.
- [x] IAM permissions were scoped to named MADAR resources.
- [x] S3 public access was blocked.
- [x] A final pre-cleanup Terraform plan reported `No changes`.
- [x] `terraform plan -destroy` was reviewed before teardown.
- [x] Terraform-managed infrastructure was removed.
- [x] Versioned S3 data was explicitly cleaned up when it blocked bucket deletion.
- [x] Final AWS Billing review showed estimated grand total `USD 0.00`.

### Final Housekeeping

- [ ] Explicitly check and remove any service-created Lambda CloudWatch log groups that remain after Lambda deletion.
- [ ] Mark Phase 2 `COMPLETED — VERIFIED — CLEANED UP` after that residual check passes.

## Engineering Review Goals

A technical reviewer should be able to understand:

1. What operational problem MADAR needed to solve.
2. Why asynchronous processing and SQS were selected.
3. How failures are retried, isolated, and later recovered.
4. How state and processed output are persisted.
5. Why Terraform is the infrastructure source of truth.
6. What was measured during success, failure, recovery, and burst tests.
7. Which security controls were actually verified.
8. What the teardown process revealed about versioned S3 data lifecycle.
9. How final cost and residual-resource checks were handled.

## Non-Goals

This phase does not require Kubernetes, EC2 worker fleets, a large frontend, complex microservices, or a custom domain. It focuses on reliable asynchronous serverless processing, Infrastructure as Code, operational verification, measured failure/scaling behavior, recovery, and cleanup.

## Case-Study Integrity

MADAR is fictional and provides realistic business context only. It is not presented as an employer, client, or paid engagement. The repository documents the actual implementation and verification performed for this engineering case study.
