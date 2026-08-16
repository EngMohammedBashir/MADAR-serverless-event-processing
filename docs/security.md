# Security Plan

## Security Goals

- Use least-privilege IAM roles for Lambda functions.
- Keep S3 Block Public Access enabled.
- Do not store AWS access keys, API secrets, tokens, or credentials in source code.
- Do not commit Terraform state or secret `.tfvars` files.
- Use AWS-managed encryption defaults where appropriate and document stronger KMS requirements separately.
- Validate all external input before queueing or processing it.
- Keep the public API exposure explicit and documented.

## IAM Checklist

- [ ] Producer and worker use separate IAM execution roles.
- [ ] Producer can access only the queue/table actions it needs.
- [ ] Worker can access only the queue, table, bucket, and notification actions it needs.
- [ ] Avoid `Action: *` where practical.
- [ ] Avoid `Resource: *` where resource-level permissions are supported.
- [ ] Lambda logging permissions are limited to required CloudWatch Logs actions.
- [ ] Review Terraform-generated IAM policy plan before apply.
- [ ] Review actual IAM roles in AWS after deployment.

## Terraform Security

- [ ] `.terraform/` is ignored.
- [ ] `terraform.tfstate*` is ignored.
- [ ] `*.tfvars` is ignored except intentionally safe example files.
- [ ] No credentials are hard-coded in provider configuration.
- [ ] AWS authentication uses the local AWS credential chain/profile/environment rather than committed keys.
- [ ] Sensitive Terraform outputs are avoided or marked `sensitive = true` where necessary.
- [ ] Terraform plan screenshots are reviewed for secrets before adding them to evidence.

## Application Security

- [ ] Validate API request shape and required fields.
- [ ] Reject invalid payloads before SQS submission.
- [ ] Do not trust SQS message contents blindly.
- [ ] Include job IDs in logs but avoid customer-sensitive data.
- [ ] Keep error responses free of stack traces and sensitive implementation details.
- [ ] Make worker processing idempotent where practical to tolerate retries.
- [ ] Use deterministic test failure values rather than unsafe arbitrary execution paths.

## S3 and Data Protection

- [ ] S3 Block Public Access remains enabled.
- [ ] Only worker permissions required for the project are granted.
- [ ] Test objects contain no real confidential data.
- [ ] DynamoDB contains only synthetic portfolio test data.
- [ ] Encryption settings are documented from the actual deployed configuration.

## API Exposure

The first lab version may use an unauthenticated API Gateway endpoint for controlled portfolio testing. If so, this must be documented accurately as a lab decision, not presented as production-ready security.

## Production Enhancements — Not Implemented Unless Verified

- Cognito or another identity provider for API authentication/authorization
- AWS WAF for public API protection where appropriate
- Customer-managed KMS keys where organizational controls require them
- Secrets Manager or Parameter Store if application secrets become necessary
- CloudTrail and centralized security monitoring
- API throttling/usage controls based on production requirements

These remain recommendations until explicitly implemented and runtime-verified.