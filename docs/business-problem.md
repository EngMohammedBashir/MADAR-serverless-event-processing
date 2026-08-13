# Business Problem and Success Criteria

## Company Scenario

A company processes customer jobs such as document uploads, order requests, or background workflows. Traffic is highly uneven: long quiet periods can be followed by sudden bursts of hundreds or thousands of jobs.

## Current Pain Points

A traditional synchronous backend creates several risks:

- Peak traffic can overload application servers.
- Requests may time out even though the work could have been processed later.
- Failed jobs can be lost without a durable queue.
- Always-on servers cost money during idle periods.
- Scaling tightly coupled components independently is difficult.
- Troubleshooting is harder when job state is not persisted clearly.

## Target Outcome

Build a serverless event-driven platform that accepts work quickly, buffers it safely, processes jobs asynchronously, records status, retries transient failures, isolates poison messages in a Dead-Letter Queue, and produces operational visibility.

## Business Flow

```text
Customer submits job
        |
        v
API accepts request quickly
        |
        v
SQS stores work durably
        |
        v
Lambda processes jobs automatically
        |
        +--> DynamoDB updates status
        +--> S3 stores file/result
        +--> SNS sends notification

Repeated failure
        |
        v
Dead-Letter Queue
```

## Acceptance Criteria

The project is complete only when the following behaviors are verified:

- [ ] API successfully accepts a valid request.
- [ ] Request becomes an SQS message.
- [ ] Lambda consumes the message automatically.
- [ ] Job state is written to DynamoDB.
- [ ] File/result data is stored in S3 when applicable.
- [ ] Multiple queued jobs are processed without manual server scaling.
- [ ] A deliberately failing job is retried.
- [ ] A repeatedly failing job reaches the DLQ.
- [ ] CloudWatch logs clearly show successful and failed processing.
- [ ] A useful CloudWatch alarm is configured and verified.
- [ ] IAM permissions are scoped to required resources/actions.
- [ ] No secrets are committed to GitHub.
- [ ] Final cleanup is documented to control cost.

## Non-Goals

The first version does not need a large frontend, Kubernetes, EC2, or complex microservices. The goal is to prove reliable asynchronous serverless processing and failure recovery.
