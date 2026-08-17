# Cost Control and Cleanup

## Cost-Control Principle

MADAR Phase 2 should prove the architecture without generating unnecessary usage or leaving temporary AWS resources running after testing is complete.

The final cost position must be verified from AWS Billing rather than assumed.

## Cost Guardrails

- Use small synthetic test payloads.
- Keep S3 objects small.
- Use controlled burst tests rather than unnecessary high-volume load generation.
- Do not enable Lambda Provisioned Concurrency for this phase.
- Do not add unrelated services.
- Review `terraform plan` before apply for unexpected resources.
- Capture runtime evidence before removing the live environment.
- Destroy the environment when further live testing is no longer needed.

## Services to Review

- API Gateway requests
- Lambda invocations and duration
- SQS requests
- DynamoDB requests/storage
- S3 storage/requests
- SNS notifications
- CloudWatch Logs/alarms

## Terraform Cleanup Workflow

```text
Final tests complete
      |
      v
Capture evidence
      |
      v
terraform plan -destroy
      |
      v
Review destruction plan
      |
      v
terraform destroy
      |
      v
Manual AWS residual-resource check
      |
      v
AWS Billing / Cost check
```

## Cleanup Checklist

- [ ] Empty/remove S3 test objects if required before bucket destruction.
- [ ] Run `terraform plan -destroy` and inspect the plan.
- [ ] Run `terraform destroy`.
- [ ] Confirm API Gateway resources are gone.
- [ ] Confirm Lambda functions and event-source mappings are gone.
- [ ] Confirm SQS main queue and DLQ are gone.
- [ ] Confirm DynamoDB project table is gone.
- [ ] Confirm S3 project bucket is gone if Phase 2 is finished.
- [ ] Confirm SNS topic/subscription is removed.
- [ ] Confirm CloudWatch alarms are removed.
- [ ] Review CloudWatch log groups because service-created logs may require separate cleanup.
- [ ] Confirm project IAM roles/policies are removed.
- [ ] Review Terraform state after destroy.
- [ ] Check AWS Billing/Cost for unexpected ongoing usage.
- [ ] Record the final cleanup and cost result in `progress.md` and the README.

## Important Terraform Note

`terraform destroy` removes only resources Terraform manages and can successfully delete. It does not replace a final AWS resource and billing review.

S3 objects, service-created log groups, manually created resources, or anything created outside Terraform must be checked explicitly.

## Current Status

Cleanup has **not** been completed yet because the live Phase 2 environment is still available for final verification. The repository must not claim cleanup or final cost verification until those steps are actually performed.
