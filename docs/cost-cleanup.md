# Cost Control and Cleanup

## Cost-Control Principle

MADAR Phase 2 was designed to prove the architecture without generating unnecessary usage or leaving temporary AWS resources running after testing.

The final cost position was verified from AWS Billing rather than assumed.

## Cost Guardrails Used

- Small synthetic test payloads
- Small S3 objects
- Controlled burst tests rather than unnecessary high-volume load generation
- No Lambda Provisioned Concurrency
- No unrelated services added to the phase
- Terraform plans reviewed before apply
- Runtime evidence captured before teardown
- Infrastructure destroyed after verification

## Services Reviewed

- API Gateway
- Lambda
- SQS
- DynamoDB
- S3
- SNS
- CloudWatch

## Cleanup Workflow Performed

```text
Final tests complete
      |
      v
Capture evidence
      |
      v
terraform plan -destroy
      |
      | 24 resources to destroy
      v
terraform destroy
      |
      +--> most resources removed
      |
      +--> S3 BucketNotEmpty
               |
               v
        delete versioned objects
               |
               v
        terraform destroy again
               |
               v
        final S3 bucket removed
      |
      v
Residual-resource checks
      |
      +--> service-created Lambda log groups found
      +--> log groups deleted explicitly
      +--> follow-up query returned []
      |
      v
AWS Billing review
```

## Cleanup Result

- [x] `terraform plan -destroy` reviewed.
- [x] First `terraform destroy` executed.
- [x] S3 versioned objects identified after `BucketNotEmpty` prevented bucket deletion.
- [x] S3 object versions explicitly deleted.
- [x] S3 version/delete-marker listing confirmed empty.
- [x] Second `terraform destroy` removed the remaining bucket.
- [x] Post-destroy Terraform plan showed 24 resources would be created on a future apply, confirming the configuration remains while the managed environment is gone.
- [x] MADAR Lambda function check returned no results.
- [x] MADAR SQS queue check returned no results.
- [x] `madar-*` DynamoDB table check returned `[]`.
- [x] MADAR SNS topic check returned `[]`.
- [x] MADAR CloudWatch metric alarm check returned `[]`.
- [x] Service-created log groups `/aws/lambda/madar-producer` and `/aws/lambda/madar-worker` identified.
- [x] Both service-created Lambda log groups deleted.
- [x] Follow-up `/aws/lambda/madar-` log-group query returned `[]`.
- [x] AWS Bills reviewed after teardown.
- [x] Estimated grand total recorded as `USD 0.00` at review time.

## S3 Versioning Cleanup Lesson

S3 versioning worked as designed: deleting the bucket resource did not automatically make existing object versions disappear. The first destroy attempt therefore failed with:

```text
BucketNotEmpty: You must delete all versions in the bucket.
```

The object versions were listed and removed explicitly. A follow-up listing returned no `Versions` or `DeleteMarkers`, and Terraform then deleted the bucket successfully.

This is an important lifecycle distinction: **destroying infrastructure and deleting versioned data are separate concerns unless the configuration deliberately automates object deletion.**

For a disposable validation environment, `force_destroy` could be considered to simplify teardown. For production data, automatic destructive behavior should be evaluated carefully against retention and recovery requirements.

## Billing Result

The AWS Bills page for August 2026 showed:

```text
Estimated grand total: USD 0.00
```

The listed Phase 2 services, including API Gateway, CloudWatch, DynamoDB, Lambda, SNS, SQS, and S3, displayed USD 0.00 at the time of final review.

No billing screenshot is stored because the billing result is documented textually and no image was required.

## Final Status

**COMPLETED — VERIFIED — CLEANED UP.**

Terraform-managed resources were removed, versioned S3 data was cleared so the bucket could be deleted, service-created Lambda CloudWatch log groups were explicitly removed, the final residual log-group query returned `[]`, and the billing review showed an estimated grand total of `USD 0.00`.
