# Business Problem and Success Criteria

## Company Scenario — Madar (مدار)

**Madar is a fictional growing digital commerce company used as the continuous business case for this cloud engineering portfolio.**

As Madar grows, its platform processes customer jobs such as order requests, document/file uploads, and background workflows. Traffic is highly uneven: long quiet periods can be followed by sudden bursts of hundreds or thousands of jobs during promotions, batch activity, or other peak periods.

This project represents **Phase 2 of the Madar Cloud Transformation Journey: Reliable Asynchronous Processing**.

## Current Pain Points

A traditional tightly coupled synchronous backend creates several risks for Madar:

- Peak traffic can overload application servers.
- Requests may time out even though the work could be processed later.
- Failed jobs can be lost without a durable queue.
- Always-on servers cost money during idle periods.
- Scaling tightly coupled components independently is difficult.
- Troubleshooting is harder when job state is not persisted clearly.
- Manual infrastructure creation is slow and difficult to reproduce consistently.

## Business Requirement

Madar needs a processing platform that can accept bursts of work quickly without forcing every job to finish during the original API request. Incoming work must be buffered safely, processed independently, observable by operations, and recoverable when processing repeatedly fails.

The solution should also avoid unnecessary always-on compute and be reproducible through Infrastructure as Code.

## Target Outcome

Build a serverless event-driven processing platform that accepts work quickly, buffers it safely, processes jobs asynchronously, records state, retries transient failures, isolates poison messages in a Dead-Letter Queue, produces operational visibility, and can be recreated from Terraform code.

## Business Flow

```text
Madar customer submits job
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

1. What business problem Madar needed to solve.
2. Why asynchronous processing and SQS were selected.
3. How failures are retried and isolated with a DLQ.
4. How job status is persisted and observed.
5. Why Terraform was selected and how the infrastructure is reproduced.
6. What was actually tested rather than merely configured.
7. How security and cost cleanup were handled.
8. How this phase advances Madar's broader cloud transformation journey.

## Non-Goals

The first version does not need a large frontend, Kubernetes, EC2, complex microservices, or a custom domain. The goal is to prove reliable asynchronous serverless processing, Infrastructure as Code, failure recovery, and operational verification.

## Portfolio Integrity Note

Madar is fictional and provides realistic business context only. It must never be presented as an employer, client, or paid engagement. All technical implementation, testing, troubleshooting, evidence, and lessons documented in this repository represent hands-on portfolio work.