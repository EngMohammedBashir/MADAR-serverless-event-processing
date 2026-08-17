# Project Progress

## Current Status

**IN PROGRESS — MADAR Phase 2 is functionally verified. Happy-path processing, SNS delivery, retry/DLQ behavior, burst testing, CloudWatch alarms, IAM least privilege, S3 public-access protection, and Terraform drift checks are complete. Cleanup and billing verification remain.**

## Project Story

MADAR is a fictional growing digital commerce company used as one continuous cloud-transformation case study.

Phase 1 established a resilient web foundation. Phase 2 addresses the next operational problem: background workloads now arrive in bursts and should not remain tightly coupled to customer-facing request processing.

The engineering response is an asynchronous, serverless event-processing layer that is implemented with Terraform and tested under success, controlled failure, and burst conditions.

## Progress Rules

- `PLANNED` = documented but not created.
- `CONFIGURED` = resource/configuration exists.
- `VERIFIED` = runtime behavior has been tested successfully.
- `FAILED / INVESTIGATING` = testing exposed a problem that requires analysis.
- `CLEANED UP` = final resource and billing checks completed.

## Phase Tracker

- [x] Business problem defined
- [x] Architecture implemented with Terraform
- [x] SQS main queue and DLQ deployed
- [x] DynamoDB table deployed
- [x] S3 archive bucket deployed with public-access protection and versioning
- [x] Producer and worker IAM roles/policies deployed
- [x] SNS topic and email subscription deployed
- [x] Producer and worker Lambda functions deployed
- [x] SQS → Worker Lambda event source mapping verified
- [x] API Gateway HTTP API and `POST /jobs` route deployed
- [x] API Gateway → Producer Lambda integration verified
- [x] Primary happy path verified end to end
- [x] DynamoDB `PROCESSED` state verified
- [x] S3 processed-event archive verified
- [x] SNS email notification verified
- [x] Worker execution verified in CloudWatch Logs
- [x] Controlled worker failure injected for DLQ testing
- [x] Retry behavior verified — three failed worker invocations observed
- [x] DLQ behavior verified — message moved after three receives
- [x] Account Lambda concurrency quota identified as `10`
- [x] 30-request burst tested — 15 producer throttles observed
- [x] 8-request burst tested — 8/8 accepted and 0 throttles
- [x] CloudWatch producer-throttling alarm deployed
- [x] CloudWatch DLQ alarm deployed and verified in `ALARM` state
- [x] IAM least-privilege review completed
- [x] S3 public-access blocking verified
- [x] Final Terraform plan returned `No changes`
- [x] Runtime and operational evidence captured
- [ ] Optional DLQ recovery/redrive test
- [ ] Terraform destroy completed
- [ ] Residual-resource check completed
- [ ] Final AWS billing check completed
- [ ] Phase 2 marked COMPLETED

## Verified Runtime Path

```text
PowerShell client
  -> HTTPS POST /jobs
  -> API Gateway
  -> Producer Lambda
  -> SQS
  -> Worker Lambda
  -> DynamoDB status = PROCESSED
  -> S3 processed JSON archive
  -> SNS email notification
  -> CloudWatch execution logs
```

A real request returned `Job accepted` and an event ID. The same event ID was found in DynamoDB with status `PROCESSED`, the corresponding JSON object was found under the S3 `processed/` prefix, and SNS delivered a success email.

## Verified Failure Path

```text
Controlled failing job
  -> SQS
  -> Worker attempt 1 FAILED
  -> Worker attempt 2 FAILED
  -> Worker attempt 3 FAILED
  -> SQS DLQ
  -> CloudWatch DLQ alarm
```

CloudWatch Logs showed three separate worker invocations failing with the intentional test exception. The DLQ then reported one available message, confirming `maxReceiveCount = 3` was exercised successfully. The `madar-dlq-messages` alarm entered the `ALARM` state.

The temporary failure condition was removed after testing and the normal worker implementation was redeployed.

## Burst / Scaling Test

### Test 1 — 30 concurrent requests

The AWS account reported an account-level Lambda concurrency limit of `10`. A 30-request concurrent burst caused the producer Lambda to scale out until that quota became the bottleneck.

Observed result:

- Some requests returned `Job accepted`.
- Some requests returned `Service Unavailable`.
- CloudWatch recorded **15 producer throttles**.
- Producer logs showed several execution environments starting concurrently.

This is recorded as a capacity-planning finding rather than hidden as a failed test.

### Test 2 — 8 concurrent requests

The test was repeated with 8 concurrent requests.

Observed result:

- **8/8 requests returned `Job accepted`.**
- CloudWatch producer `Throttles` reported **0** for the test window.

Conclusion: the application behaves correctly within the current quota. A larger production workload would require a higher Lambda concurrency service quota based on measured demand.

## Security Review

Producer permissions are restricted to:

- `sqs:SendMessage` on `madar-processing-queue`
- DynamoDB item operations on `madar-events`

Worker permissions are restricted to:

- SQS receive/delete/attributes on `madar-processing-queue`
- DynamoDB item operations on `madar-events`
- S3 object access under the MADAR archive bucket
- `sns:Publish` on `madar-processing-notifications`

No broad `Resource = "*"` is used in these application policies where resource-level permissions are supported.

The S3 archive bucket was verified with:

```text
BlockPublicAcls        = true
IgnorePublicAcls       = true
BlockPublicPolicy      = true
RestrictPublicBuckets = true
```

## Current Resource State

| Component | State | Evidence |
|---|---|---|
| API Gateway HTTP API | VERIFIED | `POST /jobs` accepted real HTTPS requests |
| Producer Lambda | VERIFIED | Happy path plus burst/throttle analysis |
| SQS main queue | VERIFIED | Events reached worker through event source mapping |
| SQS DLQ | VERIFIED | Controlled message failed three receives and moved to DLQ |
| Worker Lambda | VERIFIED | Success and controlled-failure executions observed |
| DynamoDB | VERIFIED | Test event reached `PROCESSED` |
| S3 | VERIFIED | Processed JSON archived; public access blocked |
| SNS | VERIFIED | Confirmed subscription received success notification |
| CloudWatch Logs | VERIFIED | Success and failure invocations observed |
| CloudWatch alarms | VERIFIED | DLQ alarm entered `ALARM`; producer alarm deployed |
| IAM | VERIFIED | Producer and worker policies reviewed for least privilege |
| Terraform drift check | VERIFIED | Final plan returned `No changes` |

## Evidence Captured

- `evidence/Screenshots/lambda-worker-sqs-trigger.png`
- `evidence/Screenshots/dynamodb-processed-event.png`
- `evidence/Screenshots/s3-processed-event-archive.png`
- `evidence/Screenshots/api-gateway-post-jobs.png`
- `evidence/Screenshots/sns-subscription-confirmed.png`
- `evidence/Screenshots/sns-job-processed-email.png`
- `evidence/Screenshots/dlq-message-after-3-failures.png`
- `evidence/Screenshots/producer-lambda-burst-throttling.png`
- `evidence/Screenshots/burst-test-8-requests-zero-throttles.png`
- `evidence/Screenshots/cloudwatch-dlq-alarm.png`
- `evidence/Screenshots/iam-least-privilege-worker-policy.png`
- `evidence/Screenshots/s3-public-access-block.png`

## Remaining Work

```text
Optional DLQ redrive/recovery test
  -> decide when live environment can be removed
  -> terraform destroy
  -> residual-resource verification
  -> final billing check
  -> mark Phase 2 COMPLETED
```

## Decisions and Notes

- Terraform remains the source of truth for infrastructure changes.
- AWS Console is used for inspection and runtime evidence, not as the primary provisioning mechanism.
- Runtime evidence is required before a component is marked `VERIFIED`.
- `aws login` temporary authentication is used instead of long-lived IAM access keys.
- Terraform state, generated ZIP packages, and local `.terraform/` data are excluded from GitHub.
- `.terraform.lock.hcl` is committed so provider selections are reproducible.
- The SNS email address is supplied locally through `TF_VAR_notification_email` rather than committed to source.
- DLQ is marked verified because a real controlled failure exercised three receives and moved a message into the DLQ.
- Burst testing records both successful behavior and discovered quota limitations.
- MADAR is fictional and provides business context for the engineering case study.
