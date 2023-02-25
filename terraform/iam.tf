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

module "iam_policy_module" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "t_iam_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.iam_policy.content
}

module "cloudwatch_logs_policy_module" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "t_cloudwatch_logs_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.cloudwatch_logs_policy.content
}

module "firehose_policy_module" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "t_s3_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.firehose_policy.content
}

module "s3_policy_module" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "t_lambda_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.s3_policy.content
}

module "lambda_policy_module" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "t_firehose_admin"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.lambda_policy.content
}