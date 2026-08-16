# Implementation Checklist

> Rule: a checkbox is marked complete only after the specific action has been performed. Runtime features are not **Verified** until tested.

## Phase 0 — Local Tooling and Cost Guardrails

- [ ] Confirm AWS Region: `us-east-1` unless intentionally changed.
- [ ] Review AWS Budget/alerts and current Billing page.
- [ ] Install Terraform.
- [ ] Verify `terraform version`.
- [ ] Verify Git installation and repository access.
- [ ] Install/configure AWS CLI if needed for Terraform authentication.
- [ ] Verify AWS identity using `aws sts get-caller-identity`.
- [ ] Confirm no long-lived AWS credentials will be committed.
- [ ] Define naming prefix and project tags.
- [ ] Review `.gitignore` before creating Terraform state.

## Phase 1 — Terraform Fundamentals

- [ ] Understand provider, resource, data source, variable, output, and state at a basic level.
- [ ] Review `versions.tf` and provider version constraints.
- [ ] Review `providers.tf` and AWS Region variable.
- [ ] Run `terraform fmt -recursive`.
- [ ] Run `terraform init`.
- [ ] Run `terraform validate`.
- [ ] Understand what `.terraform/`, `.terraform.lock.hcl`, and `terraform.tfstate` are.
- [ ] Confirm `terraform.tfstate` and `.tfvars` are excluded from Git.

## Phase 2 — Core Data and Messaging Infrastructure

- [ ] Define DynamoDB job-status table in Terraform.
- [ ] Define partition key strategy using `job_id`.
- [ ] Define S3 results/input bucket if required by the demo workflow.
- [ ] Keep S3 Block Public Access enabled.
- [ ] Define main SQS queue.
- [ ] Define SQS Dead-Letter Queue.
- [ ] Configure redrive policy.
- [ ] Choose visibility timeout appropriate for worker runtime.
- [ ] Add useful Terraform outputs for resource names/ARNs.

## Phase 3 — IAM

- [ ] Define producer Lambda execution role in Terraform.
- [ ] Grant CloudWatch Logs permissions required by producer.
- [ ] Grant producer only required DynamoDB/SQS permissions.
- [ ] Define worker Lambda execution role in Terraform.
- [ ] Grant worker only required SQS/DynamoDB/S3/SNS permissions.
- [ ] Avoid `Action: *` where practical.
- [ ] Avoid `Resource: *` where resource-level permissions are supported.
- [ ] Review final IAM policy JSON before deployment.

## Phase 4 — Lambda Application Code

- [ ] Implement producer Lambda in Python.
- [ ] Validate input.
- [ ] Generate unique job ID.
- [ ] Persist initial `QUEUED` state.
- [ ] Send normalized message to SQS.
- [ ] Return fast response containing job ID.
- [ ] Implement worker Lambda in Python.
- [ ] Parse queue message safely.
- [ ] Mark job `PROCESSING`.
- [ ] Perform deterministic demo business operation.
- [ ] Write S3 result if included.
- [ ] Mark job `SUCCEEDED`.
- [ ] Publish SNS notification if included.
- [ ] Include job ID in structured logs.
- [ ] Add deterministic failure trigger for DLQ testing.

## Phase 5 — Lambda Infrastructure and Event Source

- [ ] Package producer Lambda for Terraform deployment.
- [ ] Package worker Lambda for Terraform deployment.
- [ ] Define producer Lambda resource.
- [ ] Define worker Lambda resource.
- [ ] Configure required environment variables.
- [ ] Define SQS event-source mapping for worker.
- [ ] Configure batch size intentionally.
- [ ] Verify SQS visibility timeout exceeds expected Lambda processing time.

## Phase 6 — API Gateway

- [ ] Choose HTTP API or REST API and document why.
- [ ] Define API Gateway in Terraform.
- [ ] Create job-submission route.
- [ ] Integrate route with producer Lambda.
- [ ] Add Lambda invoke permission.
- [ ] Configure CORS only if actually required.
- [ ] Output deployed API endpoint.

## Phase 7 — SNS and CloudWatch

- [ ] Define SNS topic.
- [ ] Add email subscription only if required for demo notification.
- [ ] Confirm email subscription manually.
- [ ] Define useful CloudWatch alarm, preferably DLQ messages > 0.
- [ ] Connect alarm to SNS where appropriate.
- [ ] Set intentional CloudWatch log retention to avoid indefinite lab logs.

## Phase 8 — Terraform Review and First Deployment

- [ ] Run `terraform fmt -recursive`.
- [ ] Run `terraform validate`.
- [ ] Run `terraform plan`.
- [ ] Read the complete plan before applying.
- [ ] Confirm no unexpected paid/high-cost resources are present.
- [ ] Run `terraform apply`.
- [ ] Save useful outputs.
- [ ] Inspect every created resource in the AWS Console.
- [ ] Update `docs/progress.md` from Planned to Configured where appropriate.

## Phase 9 — Core Runtime Verification

- [ ] Submit valid request through API Gateway.
- [ ] Verify producer Lambda invocation.
- [ ] Verify SQS message path.
- [ ] Verify worker Lambda invocation.
- [ ] Verify DynamoDB state lifecycle.
- [ ] Verify S3 output where used.
- [ ] Verify SNS notification where used.
- [ ] Verify API response job ID maps to persisted job state.

## Phase 10 — Failure and Recovery Verification

- [ ] Submit deterministic failure job.
- [ ] Verify worker failure leaves message for retry.
- [ ] Observe SQS ApproximateReceiveCount increase.
- [ ] Verify message reaches DLQ after configured retries.
- [ ] Confirm failed job remains diagnosable by job ID.
- [ ] Verify DLQ CloudWatch alarm behavior where practical.
- [ ] Document a safe replay/recovery procedure.
- [ ] Recover or replay one test message if practical.

## Phase 11 — Burst / Scaling Verification

- [ ] Submit multiple jobs quickly.
- [ ] Observe queue depth rise.
- [ ] Observe Lambda invocation/concurrency behavior.
- [ ] Verify successful jobs complete without manual server scaling.
- [ ] Verify DynamoDB status consistency.
- [ ] Record actual request count, processing duration, queue metrics, and Lambda metrics.

## Phase 12 — Security Review

- [ ] Confirm S3 remains private.
- [ ] Confirm separate least-privilege Lambda roles.
- [ ] Confirm no secrets/access keys/tokens in code or Git history.
- [ ] Confirm Terraform state is not committed.
- [ ] Review CloudWatch logs for accidental sensitive data.
- [ ] Document API authentication as implemented or production recommendation.
- [ ] Document WAF/KMS/Secrets Manager as implemented or recommendations only.

## Phase 13 — Portfolio Evidence and Documentation

- [ ] Capture architecture diagram after implementation stabilizes.
- [ ] Capture Terraform `plan` summary without exposing sensitive values.
- [ ] Capture API successful response.
- [ ] Capture SQS processing/burst evidence.
- [ ] Capture Lambda logs showing job ID traceability.
- [ ] Capture DynamoDB job-state evidence.
- [ ] Capture DLQ failure evidence.
- [ ] Capture CloudWatch alarm/metrics evidence.
- [ ] Capture final successful workflow result.
- [ ] Store screenshots under `evidence/` with descriptive filenames.
- [ ] Keep only the strongest evidence embedded in the final README.
- [ ] Update `architecture.md` from planned to actual.
- [ ] Update `testing-verification.md` with observed results.
- [ ] Update `lessons-learned.md` with real engineering findings.
- [ ] Synchronize `progress.md`.

## Phase 14 — Cleanup and Final Cost Verification

- [ ] Review `terraform plan -destroy` before cleanup.
- [ ] Run `terraform destroy` after final evidence collection.
- [ ] Confirm Terraform reports zero managed resources afterward.
- [ ] Check API Gateway for residual APIs/stages.
- [ ] Check Lambda functions/event mappings.
- [ ] Check SQS main queue and DLQ.
- [ ] Check DynamoDB tables.
- [ ] Check S3 bucket/objects and manually empty if Terraform deletion requires it.
- [ ] Check SNS topics/subscriptions.
- [ ] Check CloudWatch alarms and log groups.
- [ ] Check project IAM roles/policies.
- [ ] Review AWS Billing/Cost Explorer after cleanup.
- [ ] Record final estimated cost.
- [ ] Mark project `COMPLETED — VERIFIED — CLEANED UP` only when final checks pass.