# ============================================================
# MADAR - CloudWatch
# Metric alarms for producer throttling and visible DLQ messages.
# ============================================================

resource "aws_cloudwatch_metric_alarm" "producer_throttles" {
  alarm_name        = "madar-producer-throttles"
  alarm_description = "Detects throttled invocations on the MADAR producer Lambda."

  namespace   = "AWS/Lambda"
  metric_name = "Throttles"
  statistic   = "Sum"
  period      = 60

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1

  dimensions = {
    FunctionName = aws_lambda_function.producer.function_name
  }

  treat_missing_data = "notBreaching"
}

# A non-empty DLQ means one or more jobs exhausted their retry attempts
# and require investigation.
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name        = "madar-dlq-messages"
  alarm_description = "Detects failed MADAR jobs that reached the dead-letter queue."

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"
  statistic   = "Maximum"
  period      = 60

  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  treat_missing_data = "notBreaching"
}
