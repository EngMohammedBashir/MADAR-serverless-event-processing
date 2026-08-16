# Cost Control and Cleanup

## Cost-Control Principle

The project should prove the architecture without generating unnecessary usage or leaving lab resources behind.

The target for this portfolio workload is **approximately USD 0.00 under the account's available Free Plan/credits**, but the final cost must be verified from AWS Billing rather than assumed.

## Cost Guardrails

- Use small synthetic test payloads.
- Keep S3 objects small.
- Avoid high-volume load tests; use enough requests to demonstrate burst behavior.
- Do not enable Lambda Provisioned Concurrency.
- Do not add services that are unrelated to the project objective.
- Set intentional CloudWatch log retention.
- Review `terraform plan` before apply for unexpected resources.
- Collect evidence and destroy the environment when testing is complete.

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
AWS Billing / Cost Explorer check
```

## Cleanup Checklist

- [ ] Empty/remove S3 test objects if required before bucket destruction.
- [ ] Run `terraform plan -destroy` and inspect the plan.
- [ ] Run `terraform destroy`.
- [ ] Confirm API Gateway resources are gone.
- [ ] Confirm Lambda functions/event-source mappings are gone.
- [ ] Confirm SQS main queue and DLQ are gone.
- [ ] Confirm DynamoDB project table is gone.
- [ ] Confirm S3 project bucket is gone if the lab is finished.
- [ ] Confirm SNS project topic/subscriptions are removed where applicable.
- [ ] Confirm CloudWatch alarms are removed.
- [ ] Review CloudWatch log groups because service-created logs may require separate cleanup depending on Terraform configuration.
- [ ] Confirm project IAM roles/policies are removed.
- [ ] Review Terraform state after destroy.
- [ ] Check AWS Billing/Cost Explorer for unexpected ongoing usage.
- [ ] Record final estimated project cost in `progress.md` and final README.

## Important Terraform Note

`terraform destroy` removes only resources that Terraform manages and can successfully delete. It does not replace a final AWS console/billing check. S3 objects, manually-created test resources, service-created log groups, or resources created outside Terraform must be reviewed explicitly.

## Documentation Rule

Cleanup is part of the engineering lifecycle. We document the final cleanup result and important cost checks; screenshots of every deletion click are not required.