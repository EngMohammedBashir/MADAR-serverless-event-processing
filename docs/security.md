# Security

## Security Goals

- Use least-privilege IAM roles for Lambda functions.
- Keep S3 Block Public Access enabled unless a specific public use case requires otherwise.
- Do not store AWS access keys, database passwords, API secrets, or tokens in source code.
- Use AWS-managed encryption defaults where appropriate and document any stronger KMS requirements.
- Keep API exposure explicit and controlled.

## IAM Checklist

- [ ] Producer Lambda can access only the queue/table actions it needs.
- [ ] Worker Lambda can access only the queue, table, bucket, and notification actions it needs.
- [ ] Avoid `Action: *` where practical.
- [ ] Avoid `Resource: *` where resource-level permissions are supported.
- [ ] Review execution roles before final verification.

## Application Security

- Validate request input before placing work on the queue.
- Do not trust queue-message contents blindly.
- Keep error responses free of sensitive implementation details.
- Use idempotent processing where practical.

## Production Enhancements

Potential hardening for a larger production environment:

- Cognito or another identity provider for API authentication.
- AWS WAF in front of the public API where appropriate.
- Customer-managed KMS keys when organizational requirements demand tighter key control.
- Secrets Manager or Parameter Store for application secrets if secrets become necessary.
- CloudTrail and centralized security monitoring.

These are recommendations until explicitly implemented and verified.
