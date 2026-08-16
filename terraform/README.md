# Terraform Infrastructure

This directory will contain the AWS infrastructure for the project.

## Learning Objective

Terraform is new in this project. The code will be built incrementally and explained resource by resource rather than pasted as one large configuration.

## Planned Workflow

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

After deployment, every resource must be inspected and runtime-tested in AWS.

Final cleanup:

```bash
terraform plan -destroy
terraform destroy
```

## Files

- `versions.tf` — Terraform/provider version requirements
- `providers.tf` — AWS provider configuration
- `variables.tf` — reusable input values
- `outputs.tf` — API/resource outputs used for testing
- `sqs.tf` — main queue, DLQ, redrive configuration
- `dynamodb.tf` — job-state table
- `s3.tf` — project object storage
- `iam.tf` — producer/worker least-privilege roles and policies
- `lambda.tf` — producer/worker functions and SQS event mapping
- `api_gateway.tf` — public job-submission API
- `sns.tf` — notification topic/subscription resources
- `cloudwatch.tf` — alarms and observability configuration

## Safety Rules

- Never commit Terraform state.
- Never commit real `.tfvars` containing secrets.
- Never hard-code AWS access keys.
- Read every `terraform plan` before apply.
- Do not claim a resource is verified because Terraform created it; test runtime behavior separately.