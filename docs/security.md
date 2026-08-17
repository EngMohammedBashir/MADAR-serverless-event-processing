# Security Verification

## Security Goals

- Use separate execution roles for producer and worker functions.
- Scope application permissions to the MADAR resources and actions each function needs.
- Keep S3 Block Public Access enabled.
- Keep credentials, tokens, state files, and local secret values out of source control.
- Use local AWS authentication rather than committed credentials.
- Keep the public API exposure explicit and documented.
- Distinguish implemented controls from future production hardening.

## Verified IAM Controls

During runtime validation, producer and worker permissions were scoped to named MADAR resources rather than broad `Resource = "*"` access where resource-level permissions are supported.

The final Terraform source was tightened after teardown so action scope also matches the current handler calls more closely.

Producer role in the final source:

- `sqs:SendMessage` on `madar-processing-queue`.
- `dynamodb:PutItem` on `madar-events`.

Worker role in the final source:

- `sqs:ReceiveMessage`, `sqs:DeleteMessage`, and `sqs:GetQueueAttributes` on `madar-processing-queue`.
- `dynamodb:UpdateItem` on `madar-events`.
- `s3:PutObject` under the MADAR archive bucket path.
- `sns:Publish` on `madar-processing-notifications`.

Lambda logging uses the AWS-managed `AWSLambdaBasicExecutionRole` policy for CloudWatch Logs access.

## Verified Terraform / Source-Control Controls

- `.terraform/` excluded from GitHub.
- `terraform.tfstate*` excluded from GitHub.
- Generated Lambda ZIP packages excluded from GitHub.
- `.terraform.lock.hcl` committed for reproducible provider selection.
- No AWS credentials hard-coded in provider configuration.
- AWS authentication uses the local AWS credential chain/login flow.
- SNS email supplied locally using `TF_VAR_notification_email` instead of being committed to Terraform source.
- Temporary cleanup helper JSON is excluded from Git.

## Verified S3 Controls

The archive bucket had all four Block Public Access settings enabled:

```text
BlockPublicAcls        = true
IgnorePublicAcls       = true
BlockPublicPolicy      = true
RestrictPublicBuckets = true
```

S3 also applied its server-side encryption default, and versioning was enabled through Terraform.

## API Exposure

The HTTP API was intentionally unauthenticated for controlled testing.

This is **not** presented as a production-ready authentication model. The phase focused on asynchronous processing behavior, failure isolation, recovery, observability, Infrastructure as Code, and cleanup.

## Application Security Notes

The test payloads were synthetic and contained no real customer-sensitive data.

The current handlers are intentionally small and readable, but they do not yet implement production-grade request schema validation, idempotency, or transactional coordination between all side effects.

Those limitations are documented rather than hidden.

## Cleanup Security Note

Terraform-managed infrastructure was destroyed after testing. Because the current Terraform configuration does not manage Lambda CloudWatch log groups explicitly, those service-created log groups require a separate residual check and deletion if they remain.

## Production Enhancements — Not Implemented

- Cognito or another identity provider for API authentication/authorization
- AWS WAF for application-layer filtering and rate controls where justified
- Customer-managed KMS keys where organizational requirements demand them
- Secrets Manager or Parameter Store if application secrets become necessary
- CloudTrail and centralized security monitoring
- Strong request validation/schema enforcement
- Idempotency controls for duplicate SQS delivery
- More robust state transitions and failure compensation
- Production API throttling and usage controls
- Explicit CloudWatch log-group management and retention in Terraform

These remain recommendations until implemented and verified.
