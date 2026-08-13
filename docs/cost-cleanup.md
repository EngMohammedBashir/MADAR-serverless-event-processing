# Cost and Cleanup

## Cost-Control Principle

The project should prove the architecture without leaving unnecessary resources running after testing.

## Services to Review

- API Gateway requests
- Lambda invocations and duration
- SQS requests
- DynamoDB read/write and storage
- S3 storage and requests
- SNS notifications
- CloudWatch Logs retention and alarms

## Cleanup Checklist

- [ ] Remove unnecessary test S3 objects.
- [ ] Delete unused SQS messages and queues when the lab is complete.
- [ ] Delete the Dead-Letter Queue after evidence is captured and the project is finished.
- [ ] Delete Lambda functions if the environment is no longer required.
- [ ] Delete API Gateway APIs when finished.
- [ ] Delete DynamoDB test tables when no longer needed.
- [ ] Review CloudWatch log groups and retention.
- [ ] Delete SNS topics/subscriptions created only for the lab if no longer needed.
- [ ] Review IAM roles/policies created specifically for the project.
- [ ] Check AWS Billing/Cost Explorer for unexpected ongoing usage.

## Documentation Rule

Cleanup is part of the project lifecycle. The repository should record that billable resources were reviewed and removed where appropriate, but screenshots of every deletion step are not required.
