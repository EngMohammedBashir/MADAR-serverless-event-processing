# Project Progress

## Current Status

**IN PROGRESS — the core MADAR serverless workload has been deployed and verified with Terraform. Happy-path processing, SNS delivery, retry/DLQ behavior, burst testing, CloudWatch alarms, IAM least privilege, and S3 public-access protection are verified. Final documentation and cleanup/billing verification remain.**

## Project Story

MADAR is a fictional company used as one continuous cloud-transformation case study. The portfolio follows the company as it grows, moves capabilities into AWS, encounters realistic engineering problems, and solves each problem with an implemented and verified cloud design.

This repository represents **Phase 2** of that journey: MADAR has already started using AWS, but its growing background workload now creates reliability and scaling problems. The engineering response is to introduce an asynchronous, serverless event-processing layer and then test it under success, failure, and burst conditions.

## Progress Rules

- `PLANNED` = documented but not created.
- `CONFIGURED` = resource/configuration exists.
- `VERIFIED` = runtime behavior has been tested successfully.
- `FAILED / INVESTIGATING` = test exposed a problem that must be diagnosed.
- `CLEANED UP` = final resource and billing checks completed.

## Phase Tracker

- [x] Business problem defined
- [x] Planned architecture documented
- [x] Terraform selected as Infrastructure as Code tool
- [x] Terraform repository structure prepared
- [x] Testing/failure/recovery plan prepared
- [x] Security checklist prepared
- [x] Cost and cleanup plan prepared
- [x] Terraform installed and verified locally
- [x] Visual Studio Code installed and repository opened
- [x] AWS CLI v2 installed and verified
- [x] AWS CLI default region selected — `us-east-1`
- [x] AWS CLI authenticated using `aws login`
- [x] AWS identity verified using `aws sts get-caller-identity`
- [x] Long-term IAM access key creation intentionally avoided
- [x] Terraform provider initialized
- [x] Terraform configuration formatted and validated
- [x] SQS main queue and DLQ deployed
- [x] DynamoDB table deployed
- [x] S3 archive bucket deployed with versioning/public-access protection
- [x] Producer and worker IAM roles/policies deployed
- [x] SNS topic deployed and worker publish permission configured
- [x] SNS email subscription created and confirmed
- [x] Producer and worker Lambda functions deployed
- [x] SQS → Worker Lambda event source mapping verified
- [x] API Gateway HTTP API and `POST /jobs` route deployed
- [x] API Gateway → Producer Lambda integration deployed
- [x] Primary happy-path runtime verified
- [x] DynamoDB `PROCESSED` state verified
- [x] S3 processed-event archive verified
- [x] Worker execution verified in CloudWatch Logs
- [x] SNS notification delivery independently verified
- [x] Controlled worker failure injected for DLQ testing
- [x] Retry behavior verified — three failed worker invocations observed
- [x] DLQ behavior verified — message moved to DLQ after three receives
- [x] Burst/scaling behavior tested
- [x] Account Lambda concurrency quota identified as 10
- [x] 30-request burst exposed producer throttling — 15 throttles observed
- [x] 8-request burst completed successfully — 8/8 accepted, 0 throttles
- [x] CloudWatch producer-throttling alarm deployed
- [x] CloudWatch DLQ alarm deployed and verified in `ALARM` state
- [x] IAM least-privilege review completed
- [x] S3 public-access blocking verified
- [x] Final Terraform plan returned `No changes`
- [x] Portfolio screenshots captured
- [ ] Optional DLQ recovery/redrive verified
- [ ] Architecture and lessons-learned documentation updated with final measured results
- [ ] Terraform destroy completed
- [ ] Residual-resource check completed
- [ ] Final AWS billing check completed
- [ ] Project marked COMPLETED

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

A real request returned `Job accepted` and an event ID. The same event ID was found in DynamoDB with status `PROCESSED`, a JSON object with that event ID was found under the S3 `processed/` prefix, and SNS delivered a processing-success email.

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

CloudWatch Logs showed three separate worker invocations failing with the intentional test exception. The DLQ then reported one available message, confirming that `maxReceiveCount = 3` was exercised successfully. The `madar-dlq-messages` CloudWatch alarm subsequently entered the `ALARM` state.

The temporary failure condition was removed from the worker after the test and the normal worker code was redeployed.

## Burst / Scaling Test

### Test 1 — 30 concurrent requests

The AWS account reported an account-level Lambda concurrency limit of `10`. A 30-request concurrent burst caused the producer Lambda to scale out until the account quota became the bottleneck.

Observed result:

- Some requests returned `Job accepted`.
- Some requests returned `Service Unavailable`.
- CloudWatch recorded **15 throttled producer invocations**.
- Producer logs showed several Lambda execution environments starting concurrently.

This was treated as a useful capacity-planning finding rather than hidden as a failed test.

### Test 2 — 8 concurrent requests

The burst test was repeated with 8 concurrent requests.

Observed result:

- **8/8 requests returned `Job accepted`.**
- CloudWatch producer `Throttles` metric reported **0** for the test window.

Conclusion: the application behaves correctly within the current account quota, while a production workload expecting larger bursts would require a higher Lambda concurrency service quota.

## Security Review

### IAM

Producer permissions are restricted to:

- `sqs:SendMessage` on `madar-processing-queue`
- DynamoDB item operations on `madar-events`

Worker permissions are restricted to:

- receive/delete/attributes on `madar-processing-queue`
- DynamoDB item operations on `madar-events`
- S3 object access under the MADAR archive bucket
- `sns:Publish` on `madar-processing-notifications`

No broad `Resource = "*"` is used in these application policies where resource-level permissions are supported.

### S3

The archive bucket was verified with all bucket-level public-access protections enabled:

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
| Producer Lambda | VERIFIED | Happy-path execution plus burst/throttle analysis |
| SQS main queue | VERIFIED | Events reached worker through event source mapping |
| SQS DLQ | VERIFIED | Controlled message failed three receives and moved to DLQ |
| Worker Lambda | VERIFIED | Success and controlled-failure executions observed |
| DynamoDB | VERIFIED | Test event reached `PROCESSED` |
| S3 | VERIFIED | Processed JSON archived; public access blocked |
| SNS | VERIFIED | Confirmed subscription received success notification |
| CloudWatch Logs | VERIFIED | Success and failure invocations observed |
| CloudWatch alarms | VERIFIED | DLQ alarm entered `ALARM`; producer throttle alarm deployed |
| IAM | VERIFIED | Producer and worker policies reviewed for least privilege |
| Terraform drift check | VERIFIED | Final plan returned `No changes` |

## 2026-08-17 — Implementation and Verification

Completed:

1. Prepared the local Terraform/AWS CLI development environment.
2. Deployed the SQS main queue and dead-letter queue.
3. Deployed DynamoDB and S3 storage resources.
4. Implemented producer and worker IAM roles and policies.
5. Deployed producer and worker Lambda functions.
6. Connected SQS to the worker Lambda.
7. Deployed API Gateway with `POST /jobs` and connected it to the producer.
8. Verified the full success path from HTTPS request to DynamoDB, S3, SNS, and CloudWatch.
9. Injected a controlled worker failure and verified three receives followed by DLQ routing.
10. Created CloudWatch alarms for producer throttling and DLQ messages.
11. Verified the DLQ alarm in a real `ALARM` state.
12. Ran a 30-request concurrent burst and discovered the account concurrency quota as the bottleneck.
13. Verified 15 producer throttles during the 30-request burst.
14. Repeated the test with 8 concurrent requests and verified 8/8 accepted with 0 throttles.
15. Reviewed producer and worker IAM permissions for least privilege.
16. Verified all four S3 public-access-block settings.
17. Ran `terraform fmt`, `terraform validate`, and a final `terraform plan`.
18. Final Terraform plan reported that the deployed infrastructure matches the configuration.
19. Captured portfolio evidence for architecture, runtime behavior, failure handling, monitoring, scaling, and security.

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

## Next Work

```text
Final architecture + lessons learned
  -> optional DLQ redrive/recovery test
  -> decide when to tear down live lab
  -> terraform destroy
  -> residual-resource check
  -> final billing verification
  -> mark project COMPLETED
```

## Decisions and Notes

- Terraform remains the source of truth for infrastructure changes.
- AWS Console is used for inspection and evidence, not as the primary provisioning mechanism.
- Runtime evidence is required before a component is marked `VERIFIED`.
- `aws login` temporary authentication is used instead of long-lived IAM access keys.
- Terraform state, generated ZIP packages, and local `.terraform/` data are excluded from GitHub.
- `.terraform.lock.hcl` is committed so provider selections are reproducible.
- The SNS email address is supplied locally through `TF_VAR_notification_email` rather than committed to Terraform source.
- DLQ is marked verified because an actual controlled failure exercised three receives and moved a message into the DLQ.
- Burst testing records both successful behavior and discovered quota limitations instead of hiding failures.
- MADAR is a fictional company; the engineering work and verification evidence are real portfolio implementation work.
