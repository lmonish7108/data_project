resource "aws_s3_bucket" "kinesis_stream_data_bucket" {
  bucket        = "data-project-push-to-s3"
  force_destroy = true
}
