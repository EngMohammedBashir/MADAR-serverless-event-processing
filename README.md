# AWS Serverless Event-Driven Application

> **Madar Cloud Transformation — Phase 2**  
> Portfolio Project 2 — Serverless, Event-Driven Architecture + Terraform Infrastructure as Code

## Company Context

**Madar (مدار)** is a fictional growing digital commerce company used as a continuous business case across this cloud engineering portfolio.

Each portfolio project addresses a realistic engineering problem that appears as Madar grows. The goal is not to collect AWS services, but to demonstrate how cloud engineering decisions solve business and operational problems.

> **Portfolio note:** Madar is fictional. The architecture, implementation, testing, troubleshooting, and evidence in this repository are real hands-on portfolio work.

### Madar Cloud Transformation Journey

```text
Phase 1  Reliability & Traffic Scaling        -> Highly Available AWS Web Architecture
Phase 2  Reliable Asynchronous Processing     -> THIS PROJECT
Phase 3  Deployment Automation                -> CI/CD
Phase 4  Security & Threat Detection          -> Cloud Security
Phase 5  Workforce Access & Identity          -> SSO / Identity Center
Phase 6  Legacy Modernization                 -> Cloud Migration
```

## Project Status

**Planning and repository preparation complete — implementation starts next.**

## Business Problem

As Madar grows, its digital platform receives uneven bursts of work from customer requests, order-processing jobs, document uploads, and background tasks. During quiet periods traffic is low; during promotions, month-end processing, or batch uploads, hundreds or thousands of jobs can arrive quickly.

A tightly coupled synchronous backend can become overloaded, time out, lose work, or require expensive always-on capacity sized for peak demand.

### Engineering Goal

Design a serverless event-driven processing pipeline that can absorb traffic bursts, decouple request intake from background processing, preserve failed work for investigation and recovery, provide operational visibility, and avoid paying for idle servers.

## Proposed Architecture

```text
Client
  |
  v
API Gateway
  |
  v
Producer Lambda
  |
  v
SQS Queue
  |
  v
Worker Lambda
  |
  +--> DynamoDB   job status
  +--> S3         files/results
  +--> SNS        notifications
  |
  v
CloudWatch Logs / Metrics / Alarms

Repeated processing failure
  |
  v
SQS Dead-Letter Queue
```

## Why This Architecture

Think of SQS as Madar's receiving warehouse: incoming jobs can arrive faster than workers can process them, but they wait safely in a queue instead of disappearing or overwhelming the application. Lambda workers consume jobs as capacity is available, while the DLQ isolates repeatedly failing jobs so they can be investigated without blocking healthy work.

This architecture is intended to demonstrate **decoupling, elasticity, failure isolation, recovery, observability, and cost-aware serverless design**.

## Infrastructure as Code

The AWS environment will be built with **Terraform** rather than by manually creating every resource in the console.

```text
Write Terraform
     |
     v
terraform validate
     |
     v
terraform plan
     |
     v
terraform apply
     |
     v
Verify resources and runtime behavior in AWS
     |
     v
terraform destroy
```

Terraform is part of the learning objective, not just a shortcut. Each resource must be understood, inspected in AWS, and runtime-tested before it can be marked **Verified**.

## What This Project Will Demonstrate

- Translating a business reliability problem into an AWS architecture
- Serverless architecture
- Event-driven and asynchronous design
- Decoupling with Amazon SQS
- Automatic Lambda scaling
- Retry behavior and Dead-Letter Queues
- Job-state persistence with DynamoDB
- S3 object storage
- SNS notifications
- CloudWatch logging, metrics, and alarms
- Least-privilege IAM
- Failure injection and recovery verification
- Infrastructure as Code with Terraform
- Terraform state, plan, apply, and destroy workflow
- Reproducible infrastructure
- Cost-aware cleanup

## Primary Technologies

**AWS:** API Gateway, Lambda, SQS, DynamoDB, S3, SNS, CloudWatch, IAM  
**Infrastructure as Code:** Terraform  
**Application code:** Python  
**Source control:** Git + GitHub

## Project Rules

1. The repository distinguishes between **Planned**, **Configured**, and **Verified**.
2. No feature is marked complete until its actual runtime behavior is tested.
3. No AWS secrets, access keys, tokens, or Terraform state files are committed.
4. Terraform changes are reviewed with `terraform plan` before `terraform apply`.
5. Cleanup is part of the project and must be verified after `terraform destroy`.
6. Portfolio claims must describe what was actually implemented and verified.
7. Madar is always identified as a fictional company; it is business context, not claimed employment or client work.

## Repository Structure

```text
.
├── README.md
├── .gitignore
├── terraform/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── api_gateway.tf
│   ├── sqs.tf
│   ├── lambda.tf
│   ├── dynamodb.tf
│   ├── s3.tf
│   ├── sns.tf
│   ├── cloudwatch.tf
│   └── iam.tf
├── lambda/
│   └── README.md
├── evidence/
│   └── README.md
└── docs/
    ├── business-problem.md
    ├── architecture.md
    ├── implementation-checklist.md
    ├── progress.md
    ├── testing-verification.md
    ├── security.md
    ├── cost-cleanup.md
    └── lessons-learned.md
```

## Documentation

- [`docs/business-problem.md`](docs/business-problem.md) — Madar business case and measurable success criteria
- [`docs/architecture.md`](docs/architecture.md) — planned technical architecture and design decisions
- [`docs/implementation-checklist.md`](docs/implementation-checklist.md) — complete build checklist
- [`docs/progress.md`](docs/progress.md) — continuously updated implementation status
- [`docs/testing-verification.md`](docs/testing-verification.md) — runtime, failure, burst, and recovery tests
- [`docs/security.md`](docs/security.md) — IAM and application security checklist
- [`docs/cost-cleanup.md`](docs/cost-cleanup.md) — cost guardrails and cleanup verification
- [`docs/lessons-learned.md`](docs/lessons-learned.md) — engineering decisions and lessons discovered during implementation

## Completion Definition

This project is not complete because resources exist. It is complete when the full path has been verified:

```text
API request
 -> producer Lambda
 -> SQS
 -> worker Lambda
 -> DynamoDB/S3
 -> notification/observability
 -> retry
 -> DLQ
 -> recovery
 -> cleanup
```

The final README will be updated from **planned architecture** to **verified architecture** using measured results and selected evidence screenshots.