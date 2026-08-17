# Lambda Application Code

This directory contains the Python application code used by MADAR Phase 2.

## Producer

`lambda/producer/handler.py`

Current behavior:

```text
API Gateway event
  -> parse request body
  -> generate UUID event_id
  -> write DynamoDB item with status QUEUED
  -> send event_id + payload to SQS
  -> return HTTP 202 with Job accepted + event_id
```

Environment variables:

- `QUEUE_URL`
- `TABLE_NAME`

## Worker

`lambda/worker/handler.py`

Current behavior:

```text
SQS event
  -> parse message
  -> read event_id + payload
  -> update DynamoDB status to PROCESSED
  -> archive payload to S3 under processed/<event_id>.json
  -> publish SNS success notification
```

Environment variables:

- `TABLE_NAME`
- `BUCKET_NAME`
- `SNS_TOPIC_ARN`

## Failure-Test History

A temporary test-only condition was added to the worker so a payload containing `force_failure = true` would raise an intentional exception.

That condition was used to verify:

```text
3 failed worker attempts
  -> DLQ
  -> CloudWatch DLQ alarm
```

The temporary failure code was removed afterward. The failed DLQ message was later redriven successfully and the same event reached `PROCESSED`.

## Current Limitations / Production Hardening

The handlers are intentionally small and readable, but they are not presented as production-complete application logic.

Future hardening should include:

- request schema validation and graceful malformed-JSON responses;
- idempotency for at-least-once SQS delivery;
- stronger coordination between the producer's DynamoDB write and SQS send;
- terminal status updates only after required worker side effects succeed;
- structured application logging with event IDs where operational tracing requires it;
- explicit error handling and failure-state recording.

No AWS credentials or secrets are stored in the Lambda source code.
