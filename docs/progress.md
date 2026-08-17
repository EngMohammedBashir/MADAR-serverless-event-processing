# Project Progress

## Current Status

**IN PROGRESS — core MADAR serverless infrastructure is deployed with Terraform and the primary happy path has been verified end-to-end. Failure/DLQ, SNS delivery, burst/scaling, alarms, security review, and cleanup remain.**

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
- [x] Producer and worker Lambda functions deployed
- [x] SQS → Worker Lambda event source mapping verified
- [x] API Gateway HTTP API and `POST /jobs` route deployed
- [x] API Gateway → Producer Lambda integration deployed
- [x] Primary happy-path runtime verified
- [x] DynamoDB `PROCESSED` state verified
- [x] S3 processed-event archive verified
- [x] Worker execution verified in CloudWatch Logs
- [x] Portfolio screenshots captured and committed
- [ ] SNS notification delivery independently verified
- [ ] Retry behavior verified
- [ ] DLQ behavior verified
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
  -> CloudWatch execution logs
```

A real request returned `Job accepted` and an event ID. The same event ID was subsequently found in DynamoDB with status `PROCESSED`, and a JSON object with that event ID was found under the S3 `processed/` prefix.

## Current Resource State

| Component | State | Evidence |
|---|---|---|
| API Gateway HTTP API | VERIFIED | `POST /jobs` accepted a real HTTPS request |
| Producer Lambda | VERIFIED | API request returned `Job accepted` and event ID |
| SQS main queue | VERIFIED | Event reached worker through SQS event source mapping |
| SQS DLQ | CONFIGURED | Redrive policy enabled, maximum receives = 3 |
| Worker Lambda | VERIFIED | SQS trigger enabled and CloudWatch invocation recorded |
| DynamoDB | VERIFIED | Test event reached `PROCESSED` |
| S3 | VERIFIED | Processed event JSON archived successfully |
| SNS | CONFIGURED | Topic and worker publish permission exist; delivery test pending |
| CloudWatch Logs | VERIFIED | Worker START/END/REPORT invocation data observed |
| CloudWatch alarms | PLANNED | Verification pending |
| IAM | CONFIGURED | Producer/worker least-privilege application permissions implemented; final review pending |

## 2026-08-17 — Implementation and Happy-Path Verification

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
16. Verified the worker invocation in CloudWatch Logs, including START, END, REPORT, duration, and memory data.
17. Captured portfolio screenshots for API Gateway, Lambda/SQS, DynamoDB, and S3.
18. Committed and pushed the Terraform, Lambda code, dependency lock file, and evidence screenshots to GitHub.

## Evidence Captured

- `evidence/Screenshots/lambda-worker-sqs-trigger.png`
- `evidence/Screenshots/dynamodb-processed-event.png`
- `evidence/Screenshots/s3-processed-event-archive.png`
- `evidence/Screenshots/api-gateway-post-jobs.png`

## Next Work

```text
SNS delivery verification
  -> controlled worker failure
  -> retry count verification
  -> DLQ verification
  -> redrive/recovery
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
- SNS is not marked verified merely because the worker has `sns:Publish`; delivery must be tested separately.
- DLQ is not marked verified merely because the redrive policy exists; an actual repeated-failure test is required.
