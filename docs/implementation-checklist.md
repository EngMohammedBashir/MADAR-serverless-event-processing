# Implementation Checklist

> A checkbox is complete only when the action has actually been performed. Runtime behavior is marked complete only after verification.

## Phase 0 — Local Tooling and Guardrails

- [x] AWS Region selected: `us-east-1`.
- [x] Terraform installed and verified.
- [x] Git repository cloned and opened in VS Code.
- [x] AWS CLI installed and authenticated.
- [x] AWS identity verified with `aws sts get-caller-identity`.
- [x] Long-lived AWS access keys avoided.
- [x] Naming and common tags defined.
- [x] `.gitignore` reviewed before Terraform state creation.

## Phase 1 — Terraform Fundamentals

- [x] Provider, resource, data source, variable, output, and state concepts used in practice.
- [x] `versions.tf` and provider constraints reviewed.
- [x] `providers.tf` and AWS Region variable configured.
- [x] `terraform init` completed.
- [x] `terraform fmt` completed.
- [x] `terraform validate` completed successfully.
- [x] `.terraform/`, `.terraform.lock.hcl`, and Terraform state behavior understood.
- [x] Terraform state and local secret variable files excluded from Git.

## Phase 2 — Core Data and Messaging Infrastructure

- [x] DynamoDB events table defined in Terraform.
- [x] `event_id` used as the partition key.
- [x] S3 processed-event archive bucket defined.
- [x] S3 Block Public Access enabled.
- [x] Main SQS queue defined.
- [x] SQS dead-letter queue defined.
- [x] Redrive policy configured with `maxReceiveCount = 3`.
- [x] SQS visibility timeout observed as 30 seconds during retry testing.

## Phase 3 — IAM

- [x] Producer Lambda execution role defined.
- [x] Worker Lambda execution role defined.
- [x] Lambda logging permissions attached.
- [x] Producer permissions scoped to required SQS/DynamoDB resources.
- [x] Worker permissions scoped to required SQS/DynamoDB/S3/SNS resources.
- [x] Application IAM policies reviewed in AWS after deployment.
- [x] No broad `Resource = "*"` used where resource-level permissions are supported.

## Phase 4 — Lambda Application Code

- [x] Producer Lambda implemented in Python.
- [x] Unique event ID generated.
- [x] Initial event state persisted in DynamoDB.
- [x] Normalized event sent to SQS.
- [x] Fast API response returned with event ID.
- [x] Worker Lambda implemented in Python.
- [x] Worker parses SQS messages.
- [x] Worker updates DynamoDB status to `PROCESSED`.
- [x] Worker writes processed payload to S3.
- [x] Worker publishes SNS success notification.
- [x] Temporary deterministic failure trigger added for DLQ testing.
- [x] Temporary failure trigger removed after verification.

## Phase 5 — Lambda Infrastructure and Event Source

- [x] Producer Lambda packaged through Terraform archive provider.
- [x] Worker Lambda packaged through Terraform archive provider.
- [x] Producer Lambda resource deployed.
- [x] Worker Lambda resource deployed.
- [x] Required environment variables configured.
- [x] SQS event-source mapping configured for worker.
- [x] Batch size configured as `1`.

## Phase 6 — API Gateway

- [x] HTTP API selected and implemented.
- [x] API Gateway defined in Terraform.
- [x] `POST /jobs` route created.
- [x] Route integrated with producer Lambda using proxy integration.
- [x] Lambda invoke permission added for API Gateway.
- [x] API endpoint output configured.

## Phase 7 — SNS and CloudWatch

- [x] SNS topic defined.
- [x] Email subscription created through Terraform.
- [x] Email subscription manually confirmed.
- [x] Producer-throttling CloudWatch alarm defined.
- [x] DLQ-visible-message CloudWatch alarm defined.
- [x] DLQ alarm verified in `ALARM` state.

## Phase 8 — Deployment Review

- [x] Terraform plans reviewed before applies.
- [x] Terraform applies completed successfully.
- [x] Created resources inspected in AWS Console.
- [x] Final `terraform plan` returned `No changes`.

## Phase 9 — Core Runtime Verification

- [x] Valid request submitted through API Gateway.
- [x] Producer Lambda invocation verified.
- [x] SQS message path verified.
- [x] Worker Lambda invocation verified.
- [x] DynamoDB `PROCESSED` state verified.
- [x] S3 output verified.
- [x] SNS notification delivery verified.
- [x] API event ID matched persisted and archived data.

## Phase 10 — Failure and Recovery Verification

- [x] Deterministic failure job submitted.
- [x] Worker failure left message for retry.
- [x] Three separate failed worker attempts observed.
- [x] Message reached DLQ after configured retries.
- [x] DLQ CloudWatch alarm behavior verified.
- [x] Temporary failure mechanism removed and normal worker redeployed.
- [ ] Optional dedicated DLQ redrive/recovery test.

## Phase 11 — Burst / Scaling Verification

- [x] 30 concurrent requests submitted.
- [x] Account Lambda concurrency quota identified as `10`.
- [x] Producer throttling observed and quantified at `15` throttles.
- [x] `Service Unavailable` responses correlated with producer throttling.
- [x] 8 concurrent requests submitted as a within-quota comparison.
- [x] 8/8 requests accepted.
- [x] Producer throttles measured as `0` during the 8-request test window.

## Phase 12 — Security Review

- [x] S3 verified private through all four Block Public Access controls.
- [x] Separate least-privilege Lambda roles verified.
- [x] Terraform state excluded from GitHub.
- [x] SNS email value kept outside committed source.
- [x] Public API exposure documented as controlled-test configuration.
- [x] Production hardening recommendations separated from implemented controls.

## Phase 13 — Evidence and Documentation

- [x] API Gateway evidence captured.
- [x] Lambda/SQS trigger evidence captured.
- [x] DynamoDB processed-state evidence captured.
- [x] S3 archive evidence captured.
- [x] SNS confirmation and delivery evidence captured.
- [x] DLQ failure evidence captured.
- [x] Burst/throttling evidence captured.
- [x] CloudWatch alarm evidence captured.
- [x] IAM least-privilege evidence captured.
- [x] S3 public-access-block evidence captured.
- [x] `architecture.md` updated from planned to implemented state.
- [x] `testing-verification.md` updated with observed results.
- [x] `lessons-learned.md` updated with actual findings.
- [x] `progress.md` synchronized with verified state.

## Phase 14 — Cleanup and Final Cost Verification

- [ ] Review `terraform plan -destroy` before cleanup.
- [ ] Run `terraform destroy` after live verification is no longer needed.
- [ ] Confirm Terraform-managed resources are removed.
- [ ] Check API Gateway, Lambda, SQS, DynamoDB, S3, SNS, CloudWatch, and IAM for residual resources.
- [ ] Review service-created CloudWatch log groups.
- [ ] Review AWS Billing/Cost after cleanup.
- [ ] Record final cost result.
- [ ] Mark Phase 2 `COMPLETED — VERIFIED — CLEANED UP` only after final checks pass.
