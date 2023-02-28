resource "aws_api_gateway_rest_api" "lambda_endpoint" {
  name = "lambda_endpoint"
}

resource "aws_api_gateway_resource" "lambda_resource" {
  path_part   = "upload"
  parent_id   = aws_api_gateway_rest_api.lambda_endpoint.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda_endpoint.id
}

resource "aws_api_gateway_method" "lambda_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_endpoint.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "api_gw_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_endpoint.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.lambda_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.push_to_kinesis.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.push_to_kinesis.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.lambda_endpoint.id}/*/${aws_api_gateway_method.lambda_post_method.http_method}${aws_api_gateway_resource.lambda_resource.path}"
}


resource "aws_api_gateway_deployment" "api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.lambda_endpoint.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.lambda_resource.id,
      aws_api_gateway_method.lambda_post_method.id,
      aws_api_gateway_integration.api_gw_lambda_integration.id,
      # If http authentication is changed we can list that trigger as well
      aws_api_gateway_method.lambda_post_method.http_method,
      aws_api_gateway_method.lambda_post_method.authorization,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gw_prod_stage" {
  deployment_id = aws_api_gateway_deployment.api_gw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_endpoint.id
  stage_name    = "prod"
}