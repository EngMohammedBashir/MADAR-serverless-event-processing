# ============================================================
# MADAR - IAM
# Separate execution roles with resource- and action-scoped access.
# ============================================================

# ------------------------------------------------------------
# Lambda trust policy
# Allows AWS Lambda to assume the execution roles below.
# ------------------------------------------------------------
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ------------------------------------------------------------
# Producer Lambda execution role
# ------------------------------------------------------------
resource "aws_iam_role" "producer_lambda_role" {
  name               = "madar-producer-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# ------------------------------------------------------------
# Worker Lambda execution role
# ------------------------------------------------------------
resource "aws_iam_role" "worker_lambda_role" {
  name               = "madar-worker-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# ============================================================
# Producer Lambda permissions
# Current handler calls: DynamoDB PutItem + SQS SendMessage.
# ============================================================
data "aws_iam_policy_document" "producer_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.jobs.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.events.arn]
  }
}

resource "aws_iam_role_policy" "producer_permissions" {
  name   = "madar-producer-permissions"
  role   = aws_iam_role.producer_lambda_role.id
  policy = data.aws_iam_policy_document.producer_permissions.json
}

# ============================================================
# Worker Lambda permissions
# Current handler calls: DynamoDB UpdateItem, S3 PutObject, SNS Publish.
# The SQS event source mapping also requires receive/delete/attributes.
# ============================================================
data "aws_iam_policy_document" "worker_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.jobs.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.events.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.event_archive.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.notifications.arn]
  }
}

resource "aws_iam_role_policy" "worker_permissions" {
  name   = "madar-worker-permissions"
  role   = aws_iam_role.worker_lambda_role.id
  policy = data.aws_iam_policy_document.worker_permissions.json
}

# ============================================================
# CloudWatch Logs permissions
# ============================================================
resource "aws_iam_role_policy_attachment" "producer_logs" {
  role       = aws_iam_role.producer_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "worker_logs" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
