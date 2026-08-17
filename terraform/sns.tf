# ============================================================
# MADAR - SNS
# Processing notifications published by the worker Lambda.
# ============================================================

resource "aws_sns_topic" "notifications" {
  name = "madar-processing-notifications"
}

# Create an email subscription only when notification_email is provided.
# AWS sends a confirmation email that must be approved manually.
resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
