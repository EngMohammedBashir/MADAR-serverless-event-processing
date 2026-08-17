# ============================================================
# MADAR - IAM
# Least-privilege IAM roles and policies for Lambda functions.
# Avoid broad wildcard permissions where resource-level
# permissions are supported.
# ============================================================


# ------------------------------------------------------------
# Lambda trust policy
# Allows AWS Lambda to assume the execution roles below.
# ------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


# ------------------------------------------------------------
# Producer Lambda execution role
# Used by the Lambda function that accepts jobs and publishes
# them to the main SQS queue.
# ------------------------------------------------------------

resource "aws_iam_role" "producer_lambda_role" {
  name               = "madar-producer-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}


# ------------------------------------------------------------
# Worker Lambda execution role
# Used by the Lambda function that processes queued jobs.
# ------------------------------------------------------------

resource "aws_iam_role" "worker_lambda_role" {
  name               = "madar-worker-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}


# ============================================================
# Producer Lambda permissions
# ============================================================

data "aws_iam_policy_document" "producer_permissions" {

  # Send new jobs to the main SQS queue.
  statement {
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.jobs.arn
    ]
  }

  # Create and update job status records in DynamoDB.
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:GetItem"
    ]

    resources = [
      aws_dynamodb_table.events.arn
    ]
  }
}


# Attach the custom producer permissions to the producer role.

resource "aws_iam_role_policy" "producer_permissions" {
  name   = "madar-producer-permissions"
  role   = aws_iam_role.producer_lambda_role.id
  policy = data.aws_iam_policy_document.producer_permissions.json
}


# ============================================================
# Worker Lambda permissions
# ============================================================

data "aws_iam_policy_document" "worker_permissions" {

  # Receive and delete jobs from the main SQS queue.
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.jobs.arn
    ]
  }

  # Read and update job state in DynamoDB.
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.events.arn
    ]
  }

  # Read and write event/result objects in the private S3 bucket.
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.event_archive.arn}/*"
    ]
  }

  # Publish processing notifications to the MADAR SNS topic.
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.notifications.arn
    ]
  }
}


# Attach the custom worker permissions to the worker role.

resource "aws_iam_role_policy" "worker_permissions" {
  name   = "madar-worker-permissions"
  role   = aws_iam_role.worker_lambda_role.id
  policy = data.aws_iam_policy_document.worker_permissions.json
}


# ============================================================
# CloudWatch Logs permissions
# AWS-managed policy allows each Lambda function to create
# log groups/streams and write execution logs.
# ============================================================

resource "aws_iam_role_policy_attachment" "producer_logs" {
  role       = aws_iam_role.producer_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "worker_logs" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}