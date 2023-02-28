resource "local_file" "lambda_parser" {
  content = templatefile("../templates/serverless/lambda.py.tmpl", {
    kinesis_stream = aws_kinesis_firehose_delivery_stream.push_to_s3_data_stream.name
  })
  filename = "${path.module}/lambda/function.py"
}

data "archive_file" "lambdazip" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"

  depends_on = [
    local_file.lambda_parser
  ]
}

resource "aws_lambda_function" "push_to_kinesis" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function.zip"
  function_name = "push_to_kinesis"
  role          = aws_iam_role.push_to_kinesis_role.arn
  handler       = "function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = data.archive_file.lambdazip.output_base64sha256

  runtime = "python3.8"
  timeout = 60

  depends_on = [
    data.archive_file.lambdazip
  ]
}