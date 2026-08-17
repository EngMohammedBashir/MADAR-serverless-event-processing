# ============================================================
# MADAR - SQS
# Main processing queue plus dead-letter queue and redrive policy.
# ============================================================

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
