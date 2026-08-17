# Lessons Learned

## Purpose

This file records engineering findings observed during MADAR Phase 2 implementation, testing, recovery, and teardown.

## Terraform Lessons

- Terraform made resource relationships much easier to reproduce than manual console creation.
- Resource references allowed Terraform to infer dependencies across SQS, Lambda, IAM, API Gateway, DynamoDB, S3, SNS, and CloudWatch.
- `terraform plan` was especially useful for catching unexpected scope before applying changes.
- The final pre-cleanup `terraform plan` returned `No changes`, confirming the deployed environment matched configuration.
- Generated state and ZIP artifacts should stay out of GitHub, while `.terraform.lock.hcl` should be committed for provider reproducibility.
- After teardown, a normal `terraform plan` showed the full stack would be recreated, which is exactly what Infrastructure as Code should provide: infrastructure can disappear while the reproducible definition remains.
- Declaring every provider used by the configuration explicitly is clearer than relying on implicit provider source resolution. The final source therefore declares both `aws` and `archive` providers.

## Event-Driven Architecture Lessons

- SQS is valuable because it decouples request intake from background processing.
- A DLQ resource is not enough by itself; failure handling should be tested with a controlled failure.
- The worker failed three times and the message moved to the DLQ exactly as configured with `maxReceiveCount = 3`.
- The temporary failure condition had to be removed and the normal worker redeployed after testing.
- Recovery should also be tested: the failed message was redriven to the source queue and the same event later reached `PROCESSED`.
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
- During runtime validation, permissions were scoped to named queue, table, bucket, and SNS resources rather than broad resource wildcards.
- Reviewing code and IAM together showed that resource scope and action scope are separate concerns. The final Terraform source was tightened after teardown so the allowed actions match the current handler calls more closely.
- S3 public-access blocking was verified instead of assumed.
- The SNS email address was passed locally through `TF_VAR_notification_email` rather than stored in Terraform source.
- Account IDs in ARNs are identifiers, not credentials; access keys, secrets, tokens, state files, and sensitive values require much stricter handling.

## Application Design Lessons

The current handlers intentionally remain small so the event flow is easy to inspect, but the tests also exposed production hardening needs:

- The producer does not implement strong schema validation or graceful malformed-JSON handling.
- A DynamoDB record is written before the SQS message is sent. Production designs should consider how to handle a partial failure between those two operations.
- The worker marks an event `PROCESSED` before the S3 write and SNS publish complete. A production workflow should define terminal state only after required side effects succeed, or use a more robust state machine/outbox design.
- SQS uses at-least-once delivery, so idempotency should be designed explicitly before real customer workloads are processed.

These are documented limitations rather than hidden assumptions.

## Operations Lessons

- CloudWatch Logs were essential for proving successful and failed Lambda invocations.
- The Lambda `Throttles` metric turned an ambiguous `Service Unavailable` result into a measurable capacity finding.
- The DLQ alarm entering `ALARM` demonstrated why operational alarms should be tested against real conditions.
- Monitoring is most useful when it maps directly to failure modes that require action.
- Service-created resources need their own lifecycle review. Lambda log groups are not automatically removed just because the Lambda function is deleted unless they are explicitly managed.

## Cost and Cleanup Lessons

- Small payloads and controlled test volumes were enough to verify behavior without large-scale load generation.
- Cleanup is part of the engineering lifecycle, not an afterthought.
- `terraform destroy` removed the managed infrastructure, but S3 versioning created an additional data-lifecycle step.
- The first destroy attempt failed because the S3 bucket still contained object versions. After those versions were explicitly deleted, Terraform removed the bucket successfully.
- PowerShell shell behavior mattered during cleanup: inline JSON quoting was error-prone, and a UTF-8 BOM in a temporary JSON file caused AWS CLI parsing to fail until the file was rewritten without the BOM.
- The final AWS Bills review showed estimated grand total `USD 0.00` at the time of review.

## MADAR Phase 2 Summary

MADAR's problem was not simply “run Lambda.” The real problem was reliable asynchronous processing as the company grew.

The engineering loop became:

```text
Business growth
  -> identify background-workload bottleneck
  -> design asynchronous architecture
  -> provision with Terraform
  -> verify happy path
  -> inject controlled failure
  -> verify retry and DLQ behavior
  -> repair and redrive failed work
  -> verify recovery
  -> test burst traffic
  -> discover concurrency quota
  -> add monitoring
  -> verify security controls
  -> destroy infrastructure
  -> solve versioned-S3 cleanup issue
  -> verify residual resources and billing
```

## Interview Summary

1. **Why SQS?** To decouple request intake from processing and provide durable buffering/retries.
2. **What happens when the worker fails?** SQS makes the message available again after the visibility timeout until retry exhaustion.
3. **Why a DLQ?** It isolates repeatedly failing messages so they do not block normal work and can be investigated safely.
4. **How was recovery proven?** The failed DLQ message was redriven to the source queue after the failure condition was removed, and the same event was later verified as `PROCESSED`.
5. **Why must workers tolerate duplicate delivery?** SQS provides at-least-once delivery semantics, so a message may be processed more than once.
6. **Why Terraform?** It makes infrastructure reproducible, reviewable, and easier to compare against deployed state.
7. **What did teardown teach?** Infrastructure deletion does not automatically solve versioned-data or service-created-resource lifecycle concerns.
8. **What would change at larger scale?** Higher Lambda concurrency quotas, stronger API controls, authentication, schema validation, idempotency, CI/CD, remote Terraform state, and additional security/observability controls based on measured production needs.
