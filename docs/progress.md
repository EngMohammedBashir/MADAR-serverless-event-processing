# Project Progress

## Current Status

**IN PROGRESS — core MADAR serverless infrastructure is deployed with Terraform. Happy-path processing, SNS email delivery, and three-attempt DLQ failure handling have been verified. Burst/scaling, alarms, security review, final architecture documentation, and cleanup remain.**

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
- [x] Portfolio screenshots captured and committed
- [ ] DLQ recovery/redrive verified
- [ ] Burst/scaling behavior verified
- [ ] CloudWatch alarms verified
- [ ] Security review completed
- [ ] Architecture updated with final measured results
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

A real request returned `Job accepted` and an event ID. The same event ID was subsequently found in DynamoDB with status `PROCESSED`, a JSON object with that event ID was found under the S3 `processed/` prefix, and SNS delivered a processing-success email.

## Verified Failure Path

```text
Controlled failing job
  -> SQS
  -> Worker attempt 1 FAILED
  -> Worker attempt 2 FAILED
  -> Worker attempt 3 FAILED
  -> SQS DLQ
```

CloudWatch Logs showed three separate worker invocations failing with the intentional DLQ-test exception. The DLQ then reported one available message, confirming that the configured `maxReceiveCount = 3` was exercised successfully.

The temporary failure condition was removed from the worker after the test and the normal worker code was redeployed.

## Current Resource State

| Component | State | Evidence |
|---|---|---|
| API Gateway HTTP API | VERIFIED | `POST /jobs` accepted real HTTPS requests |
| Producer Lambda | VERIFIED | API request returned `Job accepted` and event ID |
| SQS main queue | VERIFIED | Events reached worker through SQS event source mapping |
| SQS DLQ | VERIFIED | Controlled message failed three worker receives and moved to DLQ |
| Worker Lambda | VERIFIED | Success and controlled-failure executions observed in CloudWatch |
| DynamoDB | VERIFIED | Test event reached `PROCESSED` |
| S3 | VERIFIED | Processed event JSON archived successfully |
| SNS | VERIFIED | Confirmed subscription received worker success notification |
| CloudWatch Logs | VERIFIED | Success and three controlled failure invocations observed |
| CloudWatch alarms | PLANNED | Verification pending |
| IAM | CONFIGURED | Producer/worker least-privilege application permissions implemented; final review pending |

## 2026-08-17 — Implementation and Verification

Completed:

1. Cloned and opened the repository in VS Code.
2. Initialized Terraform and installed the AWS provider plus archive provider.
3. Deployed `madar-processing-queue` and `madar-processing-dlq`.
4. Verified the SQS redrive policy points to the DLQ with `maxReceiveCount = 3`.
5. Deployed the `madar-events` DynamoDB table using on-demand capacity.
6. Deployed the S3 processed-event archive bucket with versioning and public-access blocking.
7. Created separate producer and worker Lambda IAM roles.
8. Added application permissions for SQS, DynamoDB, S3, and SNS as required by each function.
9. Deployed `madar-producer` and `madar-worker` using Python 3.13.
10. Connected the SQS main queue to `madar-worker` with batch size 1.
11. Deployed the `madar-api` API Gateway HTTP API with `POST /jobs`.
12. Connected API Gateway to `madar-producer` using Lambda proxy integration.
13. Sent a real HTTPS POST request from PowerShell and received `Job accepted` with an event ID.
14. Verified the event reached DynamoDB with status `PROCESSED`.
15. Verified the corresponding JSON object was archived under the S3 `processed/` prefix.
16. Verified the worker invocation in CloudWatch Logs.
17. Added an SNS email subscription through Terraform without storing the email in repository code.
18. Confirmed the SNS email subscription manually.
19. Sent a second real job and verified receipt of the SNS `MADAR Job Processed` email.
20. Added a temporary controlled failure condition to the worker solely for DLQ testing.
21. Sent a failing job and observed three separate failed worker invocations in CloudWatch Logs.
22. Verified the failed message moved to `madar-processing-dlq` and the DLQ reported one available message.
23. Removed the temporary controlled-failure code and redeployed the normal worker implementation.
24. Captured and committed portfolio evidence for API Gateway, Lambda/SQS, DynamoDB, S3, SNS, and DLQ behavior.

## Evidence Captured

- `evidence/Screenshots/lambda-worker-sqs-trigger.png`
- `evidence/Screenshots/dynamodb-processed-event.png`
- `evidence/Screenshots/s3-processed-event-archive.png`
- `evidence/Screenshots/api-gateway-post-jobs.png`
- `evidence/Screenshots/sns-subscription-confirmed.png`
- `evidence/Screenshots/sns-job-processed-email.png`
- `evidence/Screenshots/dlq-message-after-3-failures.png`

## Next Work

```text
Optional DLQ redrive/recovery test
  -> burst/scaling test
  -> CloudWatch alarms
  -> security review
  -> final architecture/results documentation
  -> terraform destroy
  -> residual-resource + billing verification
```

## Decisions and Notes

- Terraform remains the source of truth for infrastructure changes.
- AWS Console is used for inspection and evidence, not as the primary provisioning mechanism.
- Runtime evidence is required before a component is marked `VERIFIED`.
- `aws login` temporary authentication is used instead of long-lived IAM access keys.
- Terraform state, generated ZIP packages, and local `.terraform/` data are excluded from GitHub.
- `.terraform.lock.hcl` is committed so provider selections are reproducible.
- The SNS email address is supplied locally through `TF_VAR_notification_email` rather than committed to Terraform source.
- DLQ is marked verified only because an actual controlled failure exercised three receives and moved a message into the DLQ.
- A dedicated DLQ redrive/recovery test has not yet been claimed as verified.
