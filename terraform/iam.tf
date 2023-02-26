resource "local_file" "iam_policy" {
  content = templatefile("../iam/iam.json.tmpl", {
    source_ip = var.aws_request_source_ip
  })
  filename = "${path.module}/parsed_iam.json"
}

resource "local_file" "cloudwatch_logs_policy" {
  content = templatefile("../iam/cloudwatch_logs.json.tmpl", {
    source_ip = var.aws_request_source_ip
  })
  filename = "${path.module}/parsed_cloudwatch_policy.json"
}

resource "local_file" "s3_policy" {
  content = templatefile("../iam/s3.json.tmpl", {
    source_ip = var.aws_request_source_ip,
    region    = var.aws_region
  })
  filename = "${path.module}/parsed_s3.json"
}

resource "local_file" "firehose_policy" {
  content = templatefile("../iam/kinesis_firehose.json.tmpl", {
    source_ip = var.aws_request_source_ip,
    region    = var.aws_region
  })
  filename = "${path.module}/parsed_kinesis_firehose.json"
}

resource "local_file" "lambda_policy" {
  content = templatefile("../iam/lambda.json.tmpl", {
    source_ip = var.aws_request_source_ip,
    region    = var.aws_region
  })
  filename = "${path.module}/parsed_lambda.json"
}

resource "aws_iam_policy" "iam_admin_policy_module" {
  name        = "t_iam_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.iam_policy.content
}

resource "aws_iam_policy" "cloudwatch_logs_policy_module" {
  name        = "t_cloudwatch_logs_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.cloudwatch_logs_policy.content
}

resource "aws_iam_policy" "firehose_policy_module" {
  name        = "t_s3_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.firehose_policy.content
}

resource "aws_iam_policy" "s3_policy_module" {
  name        = "t_lambda_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.s3_policy.content
}

resource "aws_iam_policy" "lambda_policy_module" {
  name        = "t_firehose_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.lambda_policy.content
}

resource "aws_iam_role" "lambda_data_project_role" {
  name        = "lambda_data_project_role"
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

resource "aws_iam_role_policy_attachment" "lambda_role_iam_attachment" {
  role       = aws_iam_role.lambda_data_project_role.name
  policy_arn = aws_iam_policy.iam_admin_policy_module.arn
}

resource "aws_iam_role_policy_attachment" "lambda_role_s3_attachment" {
  role       = aws_iam_role.lambda_data_project_role.name
  policy_arn = aws_iam_policy.s3_policy_module.arn
}

resource "aws_iam_role_policy_attachment" "lambda_role_cloudwatch_attachment" {
  role       = aws_iam_role.lambda_data_project_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy_module.arn
}

resource "aws_iam_role_policy_attachment" "lambda_role_lambda_attachment" {
  role       = aws_iam_role.lambda_data_project_role.name
  policy_arn = aws_iam_policy.lambda_policy_module.arn
}

resource "aws_iam_group" "user_group" {
  name = "data_project_user_group"
}

resource "aws_iam_group_policy_attachment" "group_iam_attachment" {
  group       = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.iam_admin_policy_module.arn
}

resource "aws_iam_group_policy_attachment" "group_s3_attachment" {
  group       = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.s3_policy_module.arn
}

resource "aws_iam_group_policy_attachment" "group_cloudwatch_attachment" {
  group       = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy_module.arn
}

resource "aws_iam_group_policy_attachment" "group_lambda_attachment" {
  group       = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.lambda_policy_module.arn
}

resource "aws_iam_group_policy_attachment" "group_firehose_attachment" {
  group       = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.firehose_policy_module.arn
}