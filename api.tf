resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_log.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      errorMessage            = "$context.error.message"
      integrationStatus      = "$context.integration.status"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "qrvey_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  integration_uri    = aws_lambda_function.qrvey_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  route_key = "POST /qrvey"
  target    = "integrations/${aws_apigatewayv2_integration.qrvey_integration.id}"
}

resource "aws_apigatewayv2_route" "get_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  route_key = "GET /qrvey"
  target    = "integrations/${aws_apigatewayv2_integration.qrvey_integration.id}"
}

resource "aws_apigatewayv2_route" "download_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  route_key = "GET /qrvey/download"
  target    = "integrations/${aws_apigatewayv2_integration.qrvey_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  route_key = "DELETE /qrvey"
  target    = "integrations/${aws_apigatewayv2_integration.qrvey_integration.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda_api.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.qrvey_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}