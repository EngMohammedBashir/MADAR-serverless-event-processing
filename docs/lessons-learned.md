# Lessons Learned

## Purpose

This file records engineering findings observed during MADAR Phase 2 implementation and testing.

## Terraform Lessons

- Terraform made resource relationships much easier to reproduce than manual console creation.
- Resource references allowed Terraform to infer dependencies across SQS, Lambda, IAM, API Gateway, DynamoDB, S3, SNS, and CloudWatch.
- `terraform plan` was especially useful for catching unexpected scope before applying changes.
- The final `terraform plan` returned `No changes`, confirming the deployed environment matched configuration.
- Generated state and ZIP artifacts should stay out of GitHub, while `.terraform.lock.hcl` should be committed for provider reproducibility.

## Event-Driven Architecture Lessons

- SQS is valuable because it decouples request intake from background processing.
- A DLQ resource is not enough by itself; failure handling should be tested with a controlled failure.
- The worker failed three times and the message moved to the DLQ exactly as configured with `maxReceiveCount = 3`.
- The temporary failure condition had to be removed and the normal worker redeployed after testing.
- Operational behavior becomes much easier to reason about when event IDs are persisted and reused across services.

## Scaling Lessons

The 30-request burst exposed a real account-level Lambda concurrency limit of `10`.

Observed result:

```text
30 concurrent requests
  -> producer scales out
  -> concurrency quota reached
  -> 15 throttles
  -> some requests return Service Unavailable
```

Repeating the test with 8 concurrent requests produced:

```text
8 concurrent requests
  -> 8/8 accepted
  -> 0 throttles
```

The lesson is that serverless architecture removes server fleet management, but it does not remove service quotas or capacity planning.

## Security Lessons

- Separate IAM roles made producer and worker permissions easier to reason about.
- Resource-level permissions were scoped to the specific queue, table, bucket path, and SNS topic required by each function.
- S3 public-access blocking was verified instead of assumed.
- The SNS email address was passed locally through `TF_VAR_notification_email` rather than stored in Terraform source.
- Account IDs in ARNs are identifiers, not credentials; access keys, secrets, tokens, state files, and sensitive values require much stricter handling.

## Operations Lessons

- CloudWatch Logs were essential for proving successful and failed Lambda invocations.
- The Lambda `Throttles` metric turned an ambiguous `Service Unavailable` result into a measurable capacity finding.
- The DLQ alarm entering `ALARM` demonstrated why operational alarms should be tested against real conditions.
- Monitoring is most useful when it maps directly to failure modes that require action.

## Cost and Cleanup Lessons

- Small payloads and controlled test volumes were enough to verify behavior without large-scale load generation.
- Cleanup is part of the engineering lifecycle, not an afterthought.
- `terraform destroy` will remove Terraform-managed resources, but a final AWS resource and billing review is still required.

## MADAR Phase 2 Summary

MADAR's problem was not simply “run Lambda.” The real problem was reliable asynchronous processing as the company grew.

The engineering loop was:

```text
Business growth
  -> identify background-workload bottleneck
  -> design asynchronous architecture
  -> provision with Terraform
  -> verify happy path
  -> inject controlled failure
  -> verify retry and DLQ behavior
  -> test burst traffic
  -> discover concurrency quota
  -> add monitoring
  -> verify security controls
  -> prepare cleanup
```

## Interview Summary

1. **Why SQS?** To decouple request intake from processing and provide durable buffering/retries.
2. **What happens when the worker fails?** SQS makes the message available again after the visibility timeout until retry exhaustion.
3. **Why a DLQ?** It isolates repeatedly failing messages so they do not block normal work and can be investigated safely.
4. **Why must workers tolerate duplicate delivery?** SQS provides at-least-once delivery semantics, so a message may be processed more than once.
5. **Why Terraform?** It makes infrastructure reproducible, reviewable, and easier to compare against deployed state.
6. **What would change at larger scale?** Higher Lambda concurrency quotas, stronger API controls, authentication, CI/CD, remote Terraform state, and additional security/observability controls based on measured production needs.
