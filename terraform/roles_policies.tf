resource "aws_iam_role_policy_attachment" "lambda_role_kinesis_attachment" {
  role       = aws_iam_role.push_to_kinesis_role.name
  policy_arn = aws_iam_policy.kinesis_policy.arn
}


resource "aws_iam_role_policy_attachment" "kinesis_role_s3_attachment" {
  role       = aws_iam_role.push_to_s3_role.name
  policy_arn = aws_iam_policy.push_to_s3_policy.arn
}
