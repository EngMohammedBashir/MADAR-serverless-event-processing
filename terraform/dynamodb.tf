# DynamoDB job-status table will be implemented here.
# Planned partition key: job_id.


resource "aws_dynamodb_table" "events" {
  name         = "madar-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }
}