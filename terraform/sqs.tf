# Amazon SQS main queue and Dead-Letter Queue will be implemented here.
# Required design points: redrive policy, visibility timeout, and observable retry behavior.

resource "aws_sqs_queue" "dlq" {
  name = "madar-processing-dlq"
}

resource "aws_sqs_queue" "jobs" {
  name = "madar-processing-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}
