output "api_endpoint" {
  description = "Public MADAR HTTP API endpoint"
  value       = aws_apigatewayv2_api.madar.api_endpoint
}

output "jobs_queue_url" {
  description = "Main SQS processing queue URL"
  value       = aws_sqs_queue.jobs.url
}

output "dlq_url" {
  description = "SQS dead-letter queue URL"
  value       = aws_sqs_queue.dlq.url
}

output "events_table_name" {
  description = "DynamoDB event-state table name"
  value       = aws_dynamodb_table.events.name
}

output "event_archive_bucket" {
  description = "S3 processed-event archive bucket name"
  value       = aws_s3_bucket.event_archive.id
}

output "notifications_topic_arn" {
  description = "SNS processing-notification topic ARN"
  value       = aws_sns_topic.notifications.arn
}
