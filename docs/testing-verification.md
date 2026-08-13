# Testing and Verification

## Core Tests

- [ ] Submit one request through API Gateway.
- [ ] Confirm the request reaches the producer Lambda.
- [ ] Confirm a message is placed in SQS.
- [ ] Confirm the worker Lambda processes the message.
- [ ] Confirm job status is stored in DynamoDB.
- [ ] Confirm S3 input/output behavior when used.
- [ ] Submit multiple requests quickly and observe queue and Lambda metrics.
- [ ] Confirm CloudWatch logs provide enough information to trace a job.
- [ ] Confirm monitoring detects an operational issue.

## Evidence

Capture only useful evidence such as API responses, queue metrics, Lambda logs, DynamoDB state, S3 results, and CloudWatch alarms.

Record observed values rather than estimates.
