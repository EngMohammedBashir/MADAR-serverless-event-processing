# Business Problem and Success Criteria

## Company Scenario

A company processes customer jobs such as document uploads, order requests, and background workflows. Traffic is highly uneven: long quiet periods can be followed by sudden bursts of hundreds or thousands of jobs.

## Current Pain Points

A traditional tightly coupled synchronous backend creates several risks:

- Peak traffic can overload application servers.
- Requests may time out even though the work could be processed later.
- Failed jobs can be lost without a durable queue.
- Always-on servers cost money during idle periods.
- Scaling tightly coupled components independently is difficult.
- Troubleshooting is harder when job state is not persisted clearly.
- Manual infrastructure creation is slow and difficult to reproduce consistently.

## Target Outcome

Build a serverless event-driven processing platform that accepts work quickly, buffers it safely, processes jobs asynchronously, records state, retries transient failures, isolates poison messages in a Dead-Letter Queue, produces operational visibility, and can be recreated from Terraform code.

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
Lambda processes job asynchronously
        |
        +--> DynamoDB updates status
        +--> S3 stores file/result
        +--> SNS sends notification

Repeated failure
        |
        v
Dead-Letter Queue
```

## Technical Success Criteria

The project is complete only when the following behaviors are verified:

- [ ] Terraform configuration validates successfully.
- [ ] `terraform plan` is reviewed before deployment.
- [ ] Terraform creates the planned AWS resources successfully.
- [ ] API Gateway accepts a valid request.
- [ ] Producer Lambda validates the request and returns a job ID quickly.
- [ ] Work becomes an SQS message.
- [ ] Worker Lambda consumes the message automatically.
- [ ] Job state is persisted in DynamoDB.
- [ ] File/result data is stored in S3 where applicable.
- [ ] Multiple queued jobs are processed without manually scaling servers.
- [ ] A deliberately failing job is retried.
- [ ] A repeatedly failing job reaches the DLQ.
- [ ] CloudWatch logs make a job traceable by job ID.
- [ ] A useful CloudWatch alarm is configured and verified where practical.
- [ ] SNS notification behavior is verified.
- [ ] IAM permissions are scoped to required resources/actions.
- [ ] No secrets or Terraform state files are committed to GitHub.
- [ ] `terraform destroy` removes Terraform-managed lab infrastructure.
- [ ] AWS consoles and Billing are checked for residual resources/cost.

## Portfolio Success Criteria

A reviewer should be able to understand within a few minutes:

1. What business problem the project solves.
2. Why asynchronous processing and SQS are used.
3. How failures are retried and isolated with a DLQ.
4. How job status is persisted and observed.
5. Why Terraform was selected and how the infrastructure is reproduced.
6. What was actually tested rather than merely configured.
7. How security and cost cleanup were handled.

## Non-Goals

The first version does not need a large frontend, Kubernetes, EC2, complex microservices, or a custom domain. The goal is to prove reliable asynchronous serverless processing, Infrastructure as Code, failure recovery, and operational verification.