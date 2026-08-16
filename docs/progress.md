# Project Progress

## Current Status

**READY TO START — planning, Terraform repository scaffold, implementation checklist, test plan, security plan, and cleanup plan are prepared.**

## Progress Rules

- `PLANNED` = documented but not created.
- `CONFIGURED` = resource/configuration exists.
- `VERIFIED` = runtime behavior has been tested successfully.
- `FAILED / INVESTIGATING` = test exposed a problem that must be diagnosed.
- `CLEANED UP` = final resource and billing checks completed.

## Phase Tracker

- [x] Business problem defined
- [x] Planned architecture documented
- [x] Terraform selected as the Infrastructure as Code tool
- [x] Terraform repository structure prepared
- [x] Complete implementation checklist prepared
- [x] Testing/failure/recovery plan prepared
- [x] Security checklist prepared
- [x] Cost and cleanup plan prepared
- [ ] Local Terraform tooling installed and verified
- [ ] AWS authentication verified locally
- [ ] Terraform core resources implemented
- [ ] Terraform validation and first plan reviewed
- [ ] First infrastructure deployment completed
- [ ] Happy-path runtime verified
- [ ] Retry behavior verified
- [ ] DLQ behavior verified
- [ ] Burst/scaling behavior verified
- [ ] CloudWatch/SNS monitoring verified
- [ ] Security review completed
- [ ] Portfolio evidence curated
- [ ] Architecture updated from planned to actual
- [ ] Terraform destroy completed
- [ ] Residual-resource check completed
- [ ] Final AWS billing check completed
- [ ] Project marked COMPLETED

## Planned Implementation Sequence

```text
Tooling
 -> Terraform fundamentals
 -> SQS/DLQ + DynamoDB + S3
 -> IAM
 -> Lambda code
 -> Lambda infrastructure
 -> API Gateway
 -> SNS/CloudWatch
 -> terraform plan/apply
 -> happy path
 -> failure + DLQ
 -> recovery
 -> burst test
 -> security review
 -> evidence
 -> destroy + billing check
```

## Decisions Made Before Implementation

- Terraform will be learned and used from the start of this project.
- AWS Console remains part of the workflow for inspection and runtime verification.
- The first Terraform implementation will use a readable root-module structure rather than advanced modules.
- Python will be used for Lambda functions.
- Runtime evidence matters more than screenshots of resource-creation forms.
- Failure and DLQ behavior are mandatory portfolio evidence, not optional extras.
- Production recommendations must be separated clearly from implemented features.

## Running Notes

Add dated notes here during implementation.

### Pre-Implementation

Repository prepared for implementation. No AWS project resources are claimed as deployed or verified yet.