resource "aws_iam_role" "push_to_kinesis_role" {
  name        = "push_to_kinesis_role"
  description = "Customer managed, should be deleted. Gives permissions to lambda for various data tasks."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "push_to_s3_role" {
  name        = "push_to_s3_role"
  description = "Customer managed, should be deleted. Gives permissions to lambda for various data tasks."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}