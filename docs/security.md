# Security Verification

## Security Goals

- Use least-privilege IAM roles for Lambda functions.
- Keep S3 Block Public Access enabled.
- Keep credentials, tokens, state files, and local secret values out of source control.
- Use local AWS authentication rather than committed credentials.
- Keep the public API exposure explicit and documented.
- Distinguish implemented controls from future production hardening.

## Verified IAM Controls

Producer role:

- `sqs:SendMessage` scoped to `madar-processing-queue`.
- DynamoDB item operations scoped to `madar-events`.

Worker role:

- SQS receive/delete/attribute actions scoped to `madar-processing-queue`.
- DynamoDB item operations scoped to `madar-events`.
- S3 object access scoped to the MADAR archive bucket path.
- `sns:Publish` scoped to `madar-processing-notifications`.

No broad `Resource = "*"` is used in these application policies where resource-level permissions are supported.

Lambda logging uses the AWS-managed `AWSLambdaBasicExecutionRole` policy for CloudWatch Logs access.

## Verified Terraform / Source-Control Controls

- `.terraform/` excluded from GitHub.
- `terraform.tfstate*` excluded from GitHub.
- Generated Lambda ZIP packages excluded from GitHub.
- `.terraform.lock.hcl` committed for reproducible provider selection.
- No AWS credentials are hard-coded in provider configuration.
- AWS authentication uses the local AWS credential chain/login flow.
- SNS email is supplied locally using `TF_VAR_notification_email` instead of being committed to Terraform source.

## Verified S3 Controls

The archive bucket has all four Block Public Access settings enabled:

```text
BlockPublicAcls        = true
IgnorePublicAcls       = true
BlockPublicPolicy      = true
RestrictPublicBuckets = true
```

The bucket also uses S3 server-side encryption defaults and versioning was enabled through Terraform.

## API Exposure

The current API Gateway HTTP API is intentionally unauthenticated for controlled testing.

This is **not** presented as a production-ready authentication model. The current phase focuses on asynchronous processing behavior, failure isolation, observability, and Infrastructure as Code.

## Application Security Notes

The current test payloads are synthetic and contain no real customer-sensitive data.

The worker uses parsed SQS message content and writes test payloads to DynamoDB/S3. Additional production input validation, schema enforcement, idempotency controls, and authentication would be required before handling real customer workloads.

## Production Enhancements — Not Implemented

- Cognito or another identity provider for API authentication/authorization
- AWS WAF for application-layer filtering and rate controls where justified
- Customer-managed KMS keys where organizational requirements demand them
- Secrets Manager or Parameter Store if application secrets become necessary
- CloudTrail and centralized security monitoring
- Stronger request validation/schema enforcement
- Idempotency controls for duplicate delivery
- Production API throttling and usage controls

These remain recommendations until implemented and verified.
