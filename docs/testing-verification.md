# Testing and Verification

## Verification Rule

Record **observed** values, request counts, runtime states, metrics, and outcomes. Do not replace actual tests with theoretical claims.

## 1. Terraform Verification

- [x] `terraform fmt` completed.
- [x] `terraform validate` passed.
- [x] Terraform plans were reviewed before apply.
- [x] Terraform applies completed successfully.
- [x] Final Terraform plan returned `No changes`.

## 2. Happy-Path End-to-End Test

- [x] Submitted a valid HTTPS `POST /jobs` request.
- [x] Received `Job accepted` with a generated event ID.
- [x] Confirmed producer Lambda execution.
- [x] Confirmed work reached SQS.
- [x] Confirmed worker Lambda consumed the message.
- [x] Confirmed DynamoDB status reached `PROCESSED`.
- [x] Confirmed processed JSON was archived in S3.
- [x] Confirmed SNS success notification reached the subscribed email.
- [x] Confirmed worker execution in CloudWatch Logs.

Verified logical path:

```text
API Gateway
 -> Producer Lambda
 -> SQS
 -> Worker Lambda
 -> DynamoDB
 -> S3
 -> SNS
```

## 3. Retry and DLQ Test

A controlled failure condition was temporarily added to the worker for a test payload.

Observed behavior:

```text
Worker attempt 1 -> FAILED
Worker attempt 2 -> FAILED
Worker attempt 3 -> FAILED
DLQ              -> 1 visible message
```

- [x] Submitted deterministic failure job.
- [x] Observed three failed worker invocations in CloudWatch Logs.
- [x] Confirmed the message moved to the DLQ after `maxReceiveCount = 3`.
- [x] Confirmed the DLQ contained one available message.
- [x] Confirmed `madar-dlq-messages` entered `ALARM` state.
- [x] Removed temporary failure logic and redeployed normal worker code.

## 4. Recovery / Redrive Test

- [ ] Dedicated DLQ redrive/recovery verification remains optional and has not been claimed as completed.

The existing DLQ test verifies failure isolation. It does not claim successful replay of the failed message.

## 5. Burst / Scaling Test

### 30 concurrent requests

Observed:

- Account Lambda concurrency limit: `10`.
- Some requests returned `Job accepted`.
- Some requests returned `Service Unavailable`.
- CloudWatch recorded **15 throttles** on `madar-producer`.
- Producer logs showed multiple execution environments starting concurrently.

### 8 concurrent requests

Observed:

- **8/8 requests returned `Job accepted`.**
- Producer `Throttles` metric reported **0** in the test window.

Conclusion: current account concurrency quota is the practical burst constraint. Larger expected production bursts would require quota planning and possibly additional request controls.

## 6. Security Verification

- [x] Producer and worker use separate IAM roles.
- [x] Application IAM policies use resource-specific permissions where supported.
- [x] S3 Block Public Access verified with all four controls enabled.
- [x] SNS email value supplied locally instead of committed to source.
- [x] Terraform state and generated deployment artifacts excluded from GitHub.

## 7. Observability Verification

- [x] CloudWatch worker logs observed for successful invocation.
- [x] CloudWatch worker logs observed for controlled failures.
- [x] Producer `Throttles` metric used to diagnose burst behavior.
- [x] Producer-throttling metric alarm deployed.
- [x] DLQ-visible-message alarm deployed.
- [x] DLQ alarm verified in `ALARM` state.

## 8. Cleanup Verification

- [ ] Run `terraform plan -destroy` when the live environment is ready to be removed.
- [ ] Run `terraform destroy`.
- [ ] Confirm Terraform-managed resources are removed.
- [ ] Review service-created CloudWatch log groups and other residual resources.
- [ ] Review AWS Billing/Cost after cleanup.

## Evidence Captured

Evidence is stored under `evidence/Screenshots/` and covers:

- API Gateway route
- Lambda SQS trigger
- DynamoDB processed state
- S3 processed archive
- SNS subscription and delivery
- DLQ after three failures
- Lambda burst throttling
- successful 8-request burst with zero throttles
- CloudWatch DLQ alarm
- worker IAM policy
- S3 public-access block

The README embeds the strongest runtime and operational evidence rather than every intermediate console screen.
