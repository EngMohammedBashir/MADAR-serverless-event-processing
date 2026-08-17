# SNS notification resources will be implemented here.
# Email subscription confirmation is a manual verification step when used.


resource "aws_sns_topic" "notifications" {
  name = "madar-processing-notifications"
}
