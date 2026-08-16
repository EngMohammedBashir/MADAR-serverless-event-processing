# Lessons Learned

## Purpose

This file records engineering lessons discovered during implementation. It should contain real observations from tests, failures, Terraform behavior, IAM debugging, event processing, and cleanup — not generic AWS definitions.

## Pre-Implementation Expectations

Questions to answer during the project:

- What did Terraform make faster or safer than manual console creation?
- What was confusing about Terraform state at first?
- Which resource dependencies did Terraform infer automatically and which needed explicit configuration?
- What caused the first failed `terraform plan` or `terraform apply`, if any?
- Which IAM permission was easiest to miss?
- How did SQS retry behavior differ from the initial expectation?
- What happened to job state when the worker failed repeatedly?
- How easy was it to trace one job across API Gateway, Lambda, SQS, and DynamoDB?
- What did the burst test actually show about queue depth and Lambda scaling?
- Did `terraform destroy` remove everything expected?
- Were any service-created or manually-created resources left behind?

## Engineering Lessons

_To be filled with verified findings during implementation._

## Terraform Lessons

_To be filled during implementation._

## Event-Driven Architecture Lessons

_To be filled during implementation._

## Security Lessons

_To be filled during implementation._

## Operations and Cost Lessons

_To be filled during implementation._

## Final Interview Summary

At project completion, add a concise explanation answering:

1. Why was SQS placed between request intake and processing?
2. What happens when the worker Lambda fails?
3. How does the DLQ improve reliability and operations?
4. Why must worker processing tolerate duplicate delivery?
5. Why was Terraform used instead of manual resource creation?
6. What would be changed for a larger production system?