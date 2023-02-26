resource "aws_kinesis_firehose_delivery_stream" "push_to_s3" {
  name        = "push-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_data_project_role.arn
    bucket_arn = aws_s3_bucket.kinesis_stream_data_bucket.arn

    buffer_interval = 60
    buffer_size     = 1
  }
}