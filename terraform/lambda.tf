# Producer and worker Lambda infrastructure will be implemented here.
# Worker event source mapping will connect SQS to the worker Lambda.


# ============================================================
# MADAR - Lambda
# Packages and deploys the producer and worker functions.
# ============================================================


# ------------------------------------------------------------
# Package Lambda source code
# Terraform creates ZIP deployment packages from local files.
# ------------------------------------------------------------

data "archive_file" "producer" {
  type        = "zip"
  source_file = "${path.module}/../lambda/producer/handler.py"
  output_path = "${path.module}/producer.zip"
}

data "archive_file" "worker" {
  type        = "zip"
  source_file = "${path.module}/../lambda/worker/handler.py"
  output_path = "${path.module}/worker.zip"
}


# ------------------------------------------------------------
# Producer Lambda
# Receives requests, records the job, then sends it to SQS.
# ------------------------------------------------------------

resource "aws_lambda_function" "producer" {
  function_name = "madar-producer"

  role    = aws_iam_role.producer_lambda_role.arn
  handler = "handler.lambda_handler"
  runtime = "python3.13"

  filename         = data.archive_file.producer.output_path
  source_code_hash = data.archive_file.producer.output_base64sha256

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      QUEUE_URL  = aws_sqs_queue.jobs.url
      TABLE_NAME = aws_dynamodb_table.events.name
    }
  }

  depends_on = [
    aws_iam_role_policy.producer_permissions,
    aws_iam_role_policy_attachment.producer_logs
  ]
}


# ------------------------------------------------------------
# Worker Lambda
# Processes SQS jobs and persists results to DynamoDB and S3.
# It can also publish processing notifications through SNS.
# ------------------------------------------------------------

resource "aws_lambda_function" "worker" {
  function_name = "madar-worker"

  role    = aws_iam_role.worker_lambda_role.arn
  handler = "handler.lambda_handler"
  runtime = "python3.13"

  filename         = data.archive_file.worker.output_path
  source_code_hash = data.archive_file.worker.output_base64sha256

  timeout     = 20
  memory_size = 128

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.events.name
      BUCKET_NAME   = aws_s3_bucket.event_archive.id
      SNS_TOPIC_ARN = aws_sns_topic.notifications.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.worker_permissions,
    aws_iam_role_policy_attachment.worker_logs
  ]
}


# ------------------------------------------------------------
# SQS -> Worker event source mapping
# AWS invokes the worker automatically when jobs enter SQS.
# ------------------------------------------------------------

resource "aws_lambda_event_source_mapping" "worker_sqs" {
  event_source_arn = aws_sqs_queue.jobs.arn
  function_name    = aws_lambda_function.worker.arn

  batch_size = 1
  enabled    = true
}
