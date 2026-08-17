# Runtime and Operational Evidence

This directory contains selected screenshots captured while validating MADAR Phase 2.

The evidence set is intentionally focused on observed behavior rather than screenshots of configuration pages with no runtime context.

## Captured Evidence

```text
Screenshots/
├── api-gateway-post-jobs.png
├── lambda-worker-sqs-trigger.png
├── dynamodb-processed-event.png
├── s3-processed-event-archive.png
├── sns-subscription-confirmed.png
├── sns-job-processed-email.png
├── dlq-message-after-3-failures.png
├── dlq-redrive-successfully-completed.png
├── dlq-redrive-recovery-processed.png
├── producer-lambda-burst-throttling.png
├── burst-test-8-requests-zero-throttles.png
├── cloudwatch-dlq-alarm.png
├── iam-least-privilege-worker-policy.png
└── s3-public-access-block.png
```

## What the Evidence Proves

- HTTPS job intake through API Gateway
- SQS-triggered worker Lambda execution
- Persisted `PROCESSED` state in DynamoDB
- Processed payload archival in S3
- Confirmed SNS subscription and delivered success email
- Three failed worker attempts followed by DLQ isolation
- Successful DLQ redrive after the failure condition was removed
- The same failed event reaching `PROCESSED` after recovery
- Producer throttling during a 30-request burst under an account concurrency quota of 10
- 8/8 accepted requests with zero producer throttles in the within-quota comparison
- CloudWatch DLQ alarm entering an actual alarm state
- Resource-scoped IAM review
- S3 Block Public Access verification

## Evidence Rule

Evidence should prove behavior, a measured condition, or a security control. The root README embeds the strongest images; the complete evidence set remains here for deeper review.

The final AWS Billing result is documented in text as `USD 0.00`; no billing screenshot is stored.
