resource "local_file" "push_to_s3_policy_json" {
  content = templatefile("../templates/iam/s3_access_policy.json.tmpl", {
    aws_region = var.aws_region
  })
  filename = "${path.module}/parsed_policies/push_to_s3_policy.json"
}

resource "aws_iam_policy" "push_to_s3_policy" {
  name        = "t_push_to_s3_policy"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.push_to_s3_policy_json.content
}

resource "local_file" "kinesis_policy_json" {
  content = templatefile("../templates/iam/kinesis_access_policy.json.tmpl", {
    aws_region = var.aws_region
  })
  filename = "${path.module}/parsed_policies/kinesis_policy.json"
}

resource "aws_iam_policy" "kinesis_policy" {
  name        = "t_kinesis_policy"
  path        = "/"
  description = "Customer managed policy, should be deleted soon"

  policy = local_file.kinesis_policy_json.content
}