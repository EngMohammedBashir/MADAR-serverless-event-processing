# Project Progress

## Current Status

**COMPLETED — VERIFIED — CLEANED UP.** MADAR Phase 2 was implemented, runtime-verified, recovered through DLQ redrive, torn down with Terraform, checked for residual resources, and reviewed in AWS Billing with an estimated grand total of `USD 0.00`.

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
- [x] Service-created Lambda CloudWatch log groups found and removed
- [x] Follow-up `/aws/lambda/madar-` log-group query returned `[]`
- [x] Final AWS Bills review showed estimated grand total `USD 0.00`
- [x] Phase 2 marked `COMPLETED — VERIFIED — CLEANED UP`

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

## Verified Failure and Recovery Path

```text
Controlled failing job
  -> SQS
  -> Worker attempt 1 FAILED
  -> Worker attempt 2 FAILED
  -> Worker attempt 3 FAILED
  -> SQS DLQ
  -> CloudWatch DLQ alarm
  -> temporary failure condition removed
  -> DLQ redrive
  -> Worker Lambda
  -> DynamoDB = PROCESSED
```

The redrive task reached **100%** with status **Successfully completed**. The original failed event ID `95653788-e897-4b5f-9ff5-281b055b6285` was then retrieved from DynamoDB with `status = PROCESSED`.

## Burst / Scaling Test

The 30-request concurrent burst exposed the account-level Lambda concurrency limit of `10` and produced **15 producer throttles**. Repeating the test with 8 concurrent requests produced **8/8 accepted** with **0 throttles**.

This is recorded as a capacity-planning finding: the serverless architecture scales, but practical capacity is still bounded by account service quotas.

## Security Review

Producer and worker permissions were scoped to named MADAR resources rather than broad resource wildcards where resource-level permissions are supported. The S3 archive bucket was verified with all four Block Public Access controls enabled. The public API remained intentionally unauthenticated for controlled testing and is documented as non-production exposure.

## Cleanup Record

```text
terraform plan -destroy
  -> 24 resources planned for removal
  -> terraform destroy
  -> most resources removed
  -> S3 delete failed: BucketNotEmpty
  -> versioned S3 objects explicitly removed
  -> terraform destroy again
  -> final S3 bucket removed
  -> residual service checks
  -> Lambda log groups removed
  -> final residual log-group query = []
```

A later `terraform plan` showed **24 resources to add**, which is the expected result after all Terraform-managed resources have been destroyed while the configuration remains in Git.

## Cost Result

The AWS Bills page for August 2026 showed:

```text
Estimated grand total: USD 0.00
```

No billing screenshot is stored because it was not required for the evidence set.

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

## Final Decision

Phase 2 is closed. No additional runtime or cleanup work remains. Future work belongs to the next MADAR transformation phase.
