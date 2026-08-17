# Project Progress

## Current Status

**FINAL CLEANUP CHECK — MADAR Phase 2 has been implemented, runtime-verified, recovered through DLQ redrive, and torn down with Terraform. Final AWS Billing review showed an estimated grand total of USD 0.00. One explicit residual check remains for service-created Lambda CloudWatch log groups.**

## Project Story

MADAR is a fictional growing digital commerce company used as one continuous cloud-transformation case study.

Phase 1 established a resilient web foundation. Phase 2 addressed the next operational problem: background workloads arrived in bursts and should not remain tightly coupled to customer-facing request processing.

The engineering response was an asynchronous, serverless event-processing layer implemented with Terraform and tested under success, controlled failure, recovery, and burst conditions.

## Progress Rules

- `PLANNED` = documented but not created.
- `CONFIGURED` = resource/configuration exists.
- `VERIFIED` = runtime behavior has been tested successfully.
- `FAILED / INVESTIGATING` = testing exposed a problem that requires analysis.
- `CLEANED UP` = resources were removed and residual/cost checks were completed.

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
- [x] DLQ redrive task completed successfully
- [x] Recovered failed event verified as `PROCESSED`
- [x] Account Lambda concurrency quota identified as `10`
- [x] 30-request burst tested — 15 producer throttles observed
- [x] 8-request burst tested — 8/8 accepted and 0 throttles
- [x] CloudWatch producer-throttling alarm deployed
- [x] CloudWatch DLQ alarm deployed and verified in `ALARM` state
- [x] Resource-scoped IAM review completed
- [x] S3 public-access blocking verified
- [x] Final pre-cleanup Terraform plan returned `No changes`
- [x] Runtime and operational evidence captured
- [x] `terraform plan -destroy` reviewed — 24 resources to destroy
- [x] Terraform-managed infrastructure destroyed
- [x] Versioned S3 object cleanup completed after first destroy exposed `BucketNotEmpty`
- [x] Final S3 bucket destroy completed
- [x] Post-destroy Terraform plan showed 24 resources would be recreated on a future apply
- [x] Residual checks returned no MADAR Lambda functions
- [x] Residual checks returned no MADAR SQS queues
- [x] Residual checks returned no `madar-*` DynamoDB tables
- [x] Residual checks returned no MADAR SNS topics
- [x] Residual checks returned no MADAR CloudWatch metric alarms
- [x] Final AWS Bills review showed estimated grand total `USD 0.00`
- [ ] Explicitly inspect/remove service-created Lambda CloudWatch log groups
- [ ] Mark Phase 2 `COMPLETED — VERIFIED — CLEANED UP`

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

## Verified Recovery Path

The failed DLQ message was redriven to its source queue after the failure condition had been removed.

```text
DLQ
  -> redrive to source queue
  -> Worker Lambda
  -> successful invocation
  -> DynamoDB = PROCESSED
```

The redrive task reached **100%** with status **Successfully completed**. The original failed event ID `95653788-e897-4b5f-9ff5-281b055b6285` was then retrieved from DynamoDB with `status = PROCESSED`.

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

Conclusion: the application behaved correctly within the current quota. A larger production workload would require a higher Lambda concurrency service quota based on measured demand.

## Security Review

During runtime validation, producer and worker permissions were scoped to named MADAR resources rather than broad resource wildcards. The final Terraform source was tightened further after teardown so action lists match the current handler calls.

The S3 archive bucket was verified with:

```text
BlockPublicAcls        = true
IgnorePublicAcls       = true
BlockPublicPolicy      = true
RestrictPublicBuckets = true
```

The public API remained intentionally unauthenticated for controlled testing and is documented as non-production exposure.

## Cleanup Record

The cleanup sequence exposed one useful operational issue:

```text
terraform plan -destroy
  -> 24 resources planned for removal
  -> terraform destroy
  -> most resources removed
  -> S3 delete failed: BucketNotEmpty
  -> versioned S3 objects explicitly removed
  -> terraform destroy again
  -> final S3 bucket removed
```

A later `terraform plan` showed **24 resources to add**, which is the expected result after all Terraform-managed resources have been destroyed while the configuration remains in Git.

Residual CLI checks returned no MADAR Lambda functions, SQS queues, DynamoDB tables, SNS topics, or CloudWatch metric alarms. The remaining explicit housekeeping check is for Lambda log groups created by the service outside Terraform management.

## Cost Result

The AWS Bills page for August 2026 showed:

```text
Estimated grand total: USD 0.00
```

API Gateway, CloudWatch, DynamoDB, Lambda, SNS, SQS, and S3 all displayed USD 0.00 at the time of final review. No billing screenshot is stored because it was not needed for the evidence set.

## Evidence Captured

- `evidence/Screenshots/lambda-worker-sqs-trigger.png`
- `evidence/Screenshots/dynamodb-processed-event.png`
- `evidence/Screenshots/s3-processed-event-archive.png`
- `evidence/Screenshots/api-gateway-post-jobs.png`
- `evidence/Screenshots/sns-subscription-confirmed.png`
- `evidence/Screenshots/sns-job-processed-email.png`
- `evidence/Screenshots/dlq-message-after-3-failures.png`
- `evidence/Screenshots/dlq-redrive-successfully-completed.png`
- `evidence/Screenshots/dlq-redrive-recovery-processed.png`
- `evidence/Screenshots/producer-lambda-burst-throttling.png`
- `evidence/Screenshots/burst-test-8-requests-zero-throttles.png`
- `evidence/Screenshots/cloudwatch-dlq-alarm.png`
- `evidence/Screenshots/iam-least-privilege-worker-policy.png`
- `evidence/Screenshots/s3-public-access-block.png`

## Remaining Work

```text
Check service-created Lambda CloudWatch log groups
  -> delete them if present
  -> synchronize final cleanup status
  -> mark Phase 2 COMPLETED — VERIFIED — CLEANED UP
```

## Decisions and Notes

- Terraform remains the source of truth for infrastructure definition.
- AWS Console and AWS CLI are used for inspection and runtime evidence, not as the primary provisioning mechanism.
- Runtime evidence is required before a component is marked `VERIFIED`.
- `aws login` temporary authentication is used instead of long-lived IAM access keys.
- Terraform state, generated ZIP packages, and local `.terraform/` data are excluded from GitHub.
- `.terraform.lock.hcl` is committed so provider selections are reproducible.
- The SNS email address is supplied locally through `TF_VAR_notification_email` rather than committed to source.
- Failure handling is marked verified because an actual controlled failure exercised three receives and moved a message into the DLQ.
- Recovery is marked verified because the same failed event was redriven and later observed as `PROCESSED`.
- Burst testing records both successful behavior and discovered quota limitations.
- MADAR is fictional and provides business context for the engineering case study.
