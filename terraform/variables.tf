variable "aws_region" {
  description = "AWS Region used for the project"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Common project name used for AWS naming and tags"
  type        = string
  default     = "serverless-event-driven"
}

variable "notification_email" {
  description = "Optional email address used for SNS subscription during the lab"
  type        = string
  default     = ""
}
