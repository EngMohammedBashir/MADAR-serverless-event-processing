# Project Progress

## Current Status

**IN PROGRESS — local Infrastructure as Code tooling is installed and AWS CLI authentication has been verified. Ready to open the repository in VS Code and begin Terraform fundamentals and implementation.**

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
- [x] Terraform installed and verified locally — Terraform v1.15.8
- [x] Visual Studio Code installed — VS Code v1.132.0
- [x] AWS CLI v2 installed and verified — AWS CLI v2.36.21
- [x] AWS CLI default region selected — us-east-1
- [x] AWS CLI authenticated using `aws login` with temporary session credentials
- [x] AWS identity verified using `aws sts get-caller-identity`
- [x] Long-term IAM access key creation intentionally avoided
- [ ] Repository opened in VS Code
- [ ] Terraform fundamentals reviewed
- [ ] Terraform provider initialized
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
- Local AWS authentication uses `aws login` temporary credentials rather than a long-lived IAM access key.
- No AWS credentials will be stored in Terraform files or committed to GitHub.

## Running Notes

### 2026-08-17 — Local Development Environment

Completed the local workstation setup for the MADAR project:

1. Installed and verified Terraform v1.15.8 on Windows.
2. Installed Visual Studio Code v1.132.0 for Terraform and application development.
3. Installed and verified AWS CLI v2.36.21.
4. Configured the working AWS Region as `us-east-1`.
5. Reviewed the IAM access-key workflow but did not create a long-term access key.
6. Used the AWS CLI `aws login` browser-based authentication flow instead.
7. Received temporary local AWS credentials for the authenticated IAM session.
8. Verified programmatic AWS connectivity and caller identity with `aws sts get-caller-identity`.
9. No MADAR AWS project resources have been created yet and no infrastructure deployment is claimed at this stage.

### Pre-Implementation

Repository planning, documentation, Terraform scaffold, testing plan, security plan, and cleanup plan were prepared before deployment.