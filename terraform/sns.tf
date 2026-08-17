# SNS notification resources will be implemented here.
# Email subscription confirmation is a manual verification step when used.


# SNS topic used by the worker Lambda to publish processing notifications.
resource "aws_sns_topic" "notifications" {
  name = "madar-processing-notifications"
}


# Create an email subscription only when notification_email is provided.
# AWS will send a confirmation email that must be approved manually.
resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
