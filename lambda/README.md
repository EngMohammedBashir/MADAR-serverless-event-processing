# Lambda Application Code

Python producer and worker functions will be added here during implementation.

Planned responsibilities:

```text
producer
 -> validate request
 -> create job_id
 -> persist QUEUED state
 -> send message to SQS
 -> return job_id quickly

worker
 -> receive SQS event
 -> mark PROCESSING
 -> execute demo work
 -> write result
 -> mark SUCCEEDED or fail deliberately for retry testing
```

The code must include job IDs in useful logs and must not contain AWS credentials or secrets.