# Testing and Verification

## Verification Rule

Record **observed** values, request counts, runtime states, metrics, and outcomes. Do not replace actual tests with theoretical claims.

## 1. Terraform Verification

- [x] `terraform fmt` completed.
- [x] `terraform validate` passed.
- [x] Terraform plans were reviewed before apply.
- [x] Terraform applies completed successfully.
- [x] Final pre-cleanup Terraform plan returned `No changes`.
- [x] `terraform plan -destroy` reviewed before teardown.
- [x] Terraform-managed infrastructure destroyed.

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

A controlled failure condition was temporarily added to the worker for one test payload.

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

The same failed message was used to prove recovery after the failure condition was removed.

- [x] Started SQS DLQ redrive to the source queue.
- [x] Redrive task reached 100% with status `Successfully completed`.
- [x] Worker invocation after redrive completed without exception.
- [x] Original failed event ID was retrieved from DynamoDB.
- [x] Original failed event reached `status = PROCESSED`.

Verified event ID:

```text
95653788-e897-4b5f-9ff5-281b055b6285
```

Verified recovery path:

```text
DLQ
 -> redrive to source queue
 -> Worker Lambda
 -> successful processing
 -> DynamoDB = PROCESSED
```

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

Conclusion: current account concurrency quota was the practical burst constraint. Larger expected production bursts would require quota planning and possibly additional request controls.

## 6. Security Verification

- [x] Producer and worker used separate IAM roles.
- [x] Application IAM policies were scoped to named MADAR resources rather than broad `Resource = "*"` access where resource-level permissions are supported.
- [x] S3 Block Public Access verified with all four controls enabled.
- [x] SNS email value supplied locally instead of committed to source.
- [x] Terraform state and generated deployment artifacts excluded from GitHub.
- [x] Final Terraform source action lists tightened after teardown to match the current handler calls.

## 7. Observability Verification

- [x] CloudWatch worker logs observed for successful invocation.
- [x] CloudWatch worker logs observed for controlled failures.
- [x] Producer `Throttles` metric used to diagnose burst behavior.
- [x] Producer-throttling metric alarm deployed.
- [x] DLQ-visible-message alarm deployed.
- [x] DLQ alarm verified in `ALARM` state.

## 8. Cleanup Verification

- [x] `terraform plan -destroy` showed 24 resources to destroy.
- [x] First `terraform destroy` removed most resources.
- [x] S3 deletion failed with `BucketNotEmpty` because versioning preserved archived object versions.
- [x] All listed S3 object versions were explicitly deleted.
- [x] `list-object-versions` returned no remaining versions or delete markers.
- [x] Second `terraform destroy` removed the final S3 bucket.
- [x] Post-destroy Terraform plan showed 24 resources would be recreated on future apply.
- [x] CLI residual check returned no MADAR Lambda functions.
- [x] CLI residual check returned no MADAR SQS queues.
- [x] CLI residual check returned no `madar-*` DynamoDB tables.
- [x] CLI residual check returned no MADAR SNS topics.
- [x] CLI residual check returned no MADAR CloudWatch metric alarms.
- [x] AWS Bills review showed estimated grand total `USD 0.00`.
- [ ] Explicitly check/remove service-created Lambda CloudWatch log groups.

## Evidence Captured

Evidence is stored under `evidence/Screenshots/` and covers:

- API Gateway route
- Lambda SQS trigger
- DynamoDB processed state
- S3 processed archive
- SNS subscription and delivery
- DLQ after three failures
- successful DLQ redrive
- recovered event reaching `PROCESSED`
- Lambda burst throttling
- successful 8-request burst with zero throttles
- CloudWatch DLQ alarm
- worker IAM policy
- S3 public-access block

No billing screenshot is stored; the billing result is recorded in text only.
