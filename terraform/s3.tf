# S3 project storage will be implemented here if used by the final workflow.
# S3 Block Public Access must remain enabled.


resource "aws_s3_bucket" "event_archive" {
  bucket_prefix = "madar-event-archive-"
}

resource "aws_s3_bucket_public_access_block" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "event_archive" {
  bucket = aws_s3_bucket.event_archive.id

  versioning_configuration {
    status = "Enabled"
  }
}