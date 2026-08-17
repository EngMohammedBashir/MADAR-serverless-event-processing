# Terraform Infrastructure

This directory defines the AWS infrastructure used for MADAR Cloud Transformation — Phase 2.

The live validation environment has been destroyed after testing, but the Terraform configuration remains the reproducible source of truth for rebuilding it.

## Workflow Used

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

Runtime behavior was then verified in AWS before teardown.

Cleanup used:

```bash
terraform plan -destroy
terraform destroy
```

## Files

- `versions.tf` — Terraform and provider version requirements
- `providers.tf` — AWS provider configuration and common tags
- `variables.tf` — reusable input values
- `outputs.tf` — API and resource outputs useful during testing
- `sqs.tf` — main queue, DLQ, and redrive configuration
- `dynamodb.tf` — event-state table
- `s3.tf` — processed-event archive bucket, versioning, and public-access blocking
- `iam.tf` — producer/worker execution roles and application permissions
- `lambda.tf` — producer/worker functions and SQS event-source mapping
- `api_gateway.tf` — public `POST /jobs` HTTP API
- `sns.tf` — notification topic and optional email subscription
- `cloudwatch.tf` — producer-throttle and DLQ-visible-message alarms

## Verified Lifecycle

Before cleanup:

```text
terraform plan
-> No changes. Your infrastructure matches the configuration.
```

Cleanup:

```text
terraform plan -destroy
-> 24 resources to destroy

terraform destroy
-> most resources removed
-> S3 bucket deletion blocked by versioned objects

remove S3 object versions
-> terraform destroy
-> final S3 bucket removed
```

After cleanup, a normal plan showed the stack would be created again on the next apply. That is expected: the live infrastructure is gone, while the code remains reproducible.

## S3 Cleanup Note

The archive bucket uses versioning. During teardown, existing object versions caused AWS to return `BucketNotEmpty` when Terraform attempted to delete the bucket.

The versions were removed explicitly, then the final bucket deletion succeeded.

For disposable environments, `force_destroy` can simplify this process, but automatic deletion of versioned data should be evaluated carefully before using it for production data.

## Safety Rules

- Never commit Terraform state.
- Never commit real `.tfvars` containing secrets or private values.
- Never hard-code AWS access keys.
- Read every `terraform plan` before apply or destroy.
- Keep generated Lambda ZIP files out of Git.
- Keep `.terraform.lock.hcl` committed for reproducible provider selection.
- Treat Terraform resource creation and runtime verification as separate steps.
- Treat service-created resources, such as Lambda log groups, as explicit cleanup items when Terraform does not manage them.
