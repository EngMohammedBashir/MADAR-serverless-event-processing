# Implementation Checklist

## Phase 0 — Guardrails

- [ ] Confirm AWS Region.
- [ ] Review current AWS Budget/alerts.
- [ ] Confirm no long-lived access keys will be stored in code.
- [ ] Decide project naming convention and tags.

## Phase 1 — Data Layer

- [ ] Create DynamoDB table for job status.
- [ ] Define partition key strategy.
- [ ] Enable suitable encryption defaults.
- [ ] Create S3 bucket for input/output objects if required.
- [ ] Block public access on the S3 bucket.
- [ ] Verify basic DynamoDB write/read manually.
- [ ] Verify S3 upload/read manually.

## Phase 2 — Queue and Failure Path

- [ ] Create main SQS queue.
- [ ] Create Dead-Letter Queue.
- [ ] Configure redrive policy.
- [ ] Choose visibility timeout appropriate for worker runtime.
- [ ] Send a manual test message.
- [ ] Receive/delete a manual test message.

## Phase 3 — IAM

- [ ] Create producer Lambda execution role.
- [ ] Grant only required CloudWatch Logs permissions.
- [ ] Grant producer only required SQS/DynamoDB permissions.
- [ ] Create worker Lambda execution role.
- [ ] Grant worker only required SQS/DynamoDB/S3/SNS permissions.
- [ ] Review policies for wildcard resources/actions.

## Phase 4 — Producer Path

- [ ] Create producer Lambda.
- [ ] Generate a unique job ID.
- [ ] Validate request input.
- [ ] Write initial job status.
- [ ] Send job to SQS.
- [ ] Return fast API response with job ID.
- [ ] Verify producer Lambda directly.

## Phase 5 — Worker Path

- [ ] Create worker Lambda.
- [ ] Configure SQS event source mapping.
- [ ] Parse queue message safely.
- [ ] Mark job `PROCESSING`.
- [ ] Perform demo business operation.
- [ ] Write output to S3 if applicable.
- [ ] Mark job `SUCCEEDED`.
- [ ] Publish SNS notification if included.
- [ ] Verify automatic queue consumption.

## Phase 6 — API Gateway

- [ ] Create REST or HTTP API.
- [ ] Create job-submission route.
- [ ] Integrate route with producer Lambda.
- [ ] Configure CORS only if needed.
- [ ] Test valid request.
- [ ] Test invalid request.
- [ ] Verify returned job ID maps to DynamoDB status.

## Phase 7 — Failure Recovery

- [ ] Add deterministic failure test case.
- [ ] Verify Lambda failure leaves message for retry.
- [ ] Observe SQS receive count increase.
- [ ] Verify message reaches DLQ after configured retries.
- [ ] Confirm failed job remains diagnosable.
- [ ] Document replay/recovery procedure.

## Phase 8 — Burst Test

- [ ] Submit multiple jobs quickly.
- [ ] Observe queue depth rise.
- [ ] Observe Lambda invocations/concurrency increase.
- [ ] Verify all successful jobs complete.
- [ ] Verify DynamoDB status consistency.
- [ ] Record actual metrics rather than estimated values.

## Phase 9 — Monitoring

- [ ] Review CloudWatch Lambda logs.
- [ ] Review SQS queue metrics.
- [ ] Review Lambda Errors/Duration/Invocations.
- [ ] Create useful alarm, e.g. DLQ messages > 0.
- [ ] Add SNS email notification if useful.
- [ ] Verify alarm behavior if practical.

## Phase 10 — Security Review

- [ ] Confirm S3 is not public.
- [ ] Confirm least-privilege IAM roles.
- [ ] Confirm no secrets/API keys in GitHub.
- [ ] Confirm encryption at rest is enabled/defaulted appropriately.
- [ ] Document API authentication as implemented or planned.
- [ ] Document WAF as implemented or production enhancement.

## Phase 11 — Final Verification

- [ ] API request accepted.
- [ ] SQS message created.
- [ ] Worker Lambda invoked.
- [ ] DynamoDB status updated.
- [ ] S3 output verified where used.
- [ ] Burst test verified.
- [ ] Retry verified.
- [ ] DLQ verified.
- [ ] Monitoring verified.
- [ ] Architecture documentation updated from planned to actual.
- [ ] `progress.md` synchronized.

## Phase 12 — Cleanup

- [ ] Delete unnecessary test objects.
- [ ] Delete/disable billable or noisy resources if lab is complete.
- [ ] Review CloudWatch log retention.
- [ ] Review S3 contents/versioning before deletion.
- [ ] Review DynamoDB/SQS/Lambda/API Gateway resources.
- [ ] Confirm no unexpected ongoing charges.
- [ ] Mark cleanup in `progress.md`.
