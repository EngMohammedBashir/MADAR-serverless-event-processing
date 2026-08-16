# Testing and Verification Plan

## Evidence Rule

Record **observed** values, timestamps, request counts, queue metrics, Lambda metrics, and results. Do not replace actual tests with theoretical statements.

## 1. Terraform Verification

- [ ] `terraform fmt -check -recursive` passes.
- [ ] `terraform validate` passes.
- [ ] `terraform plan` contains only expected resources/changes.
- [ ] `terraform apply` completes successfully.
- [ ] Terraform outputs return the expected API endpoint and resource identifiers.
- [ ] AWS Console inspection matches the planned infrastructure.

## 2. Happy-Path End-to-End Test

- [ ] Submit one valid API request.
- [ ] Record HTTP response code and returned job ID.
- [ ] Confirm producer Lambda invocation.
- [ ] Confirm work is published to SQS.
- [ ] Confirm worker Lambda consumes the message.
- [ ] Confirm DynamoDB state transitions through expected statuses.
- [ ] Confirm S3 result where used.
- [ ] Confirm SNS notification where used.
- [ ] Confirm CloudWatch logs can trace the same job ID end to end.

Expected logical path:

```text
API Gateway
 -> Producer Lambda
 -> SQS
 -> Worker Lambda
 -> DynamoDB/S3
 -> SNS
```

## 3. Invalid Input Test

- [ ] Send malformed or missing required input.
- [ ] Verify producer rejects it.
- [ ] Verify rejected input is not placed on SQS.
- [ ] Verify response does not expose stack traces or sensitive details.

## 4. Retry and DLQ Test

- [ ] Submit deterministic failure job.
- [ ] Observe repeated worker failure.
- [ ] Record receive-attempt behavior.
- [ ] Confirm the message reaches the DLQ after configured retries.
- [ ] Confirm the failed job remains traceable.
- [ ] Confirm the DLQ alarm triggers where practical.

Expected failure path:

```text
SQS
 -> Worker Lambda
 -> failure
 -> retry
 -> retry limit
 -> DLQ
 -> CloudWatch alarm
 -> SNS notification
```

## 5. Recovery / Replay Test

- [ ] Identify failed test message safely.
- [ ] Document why it failed.
- [ ] Correct the deterministic failure condition or use a known-success payload.
- [ ] Replay/redrive one test message if practical.
- [ ] Verify final job success after recovery.

## 6. Burst Test

- [ ] Submit a documented number of requests quickly.
- [ ] Record request count.
- [ ] Observe SQS `ApproximateNumberOfMessagesVisible`.
- [ ] Observe Lambda Invocations/ConcurrentExecutions where available.
- [ ] Record processing completion time.
- [ ] Verify no successful job is lost.
- [ ] Verify final DynamoDB job states are consistent.

Do not claim a specific throughput until it has been measured.

## 7. Security Verification

- [ ] S3 public access is blocked.
- [ ] Producer/worker IAM roles are separate and scoped.
- [ ] GitHub contains no Terraform state, credentials, or tokens.
- [ ] Logs contain no accidental secrets.

## 8. Cleanup Verification

- [ ] `terraform destroy` completes.
- [ ] Terraform state reports no remaining managed resources.
- [ ] AWS Console checks confirm no unexpected project resources remain.
- [ ] Billing/Cost Explorer is reviewed after cleanup.

## Evidence to Capture

Capture only portfolio-quality evidence:

- Terraform validation/plan summary
- API response with job ID
- SQS queue/burst metric
- Lambda structured log with job ID
- DynamoDB job state
- S3 output if used
- DLQ message/failure path
- CloudWatch alarm/metric
- Final successful result
- Final Billing/cleanup verification

Screenshots belong in `evidence/`. The final README should embed only the strongest images rather than every screenshot.