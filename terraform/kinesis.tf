resource "aws_kinesis_firehose_delivery_stream" "push_to_s3_data_stream" {
  name        = "push-to-s3-data-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.push_to_s3_role.arn
    bucket_arn = aws_s3_bucket.kinesis_stream_data_bucket.arn

    buffer_interval = 60
    buffer_size     = 1
  }
}