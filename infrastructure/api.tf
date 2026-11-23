variable "portfolio_origin" {
  description = "Portfolio website origin, including https:// and excluding paths."
  type        = string
}

resource "aws_apigatewayv2_api" "counter" {
  name          = "cloud-production-platform-counter"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      var.portfolio_origin,
      "http://localhost:4321",
      "http://127.0.0.1:4321"
    ]
    allow_methods = ["POST"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "counter" {
  api_id                 = aws_apigatewayv2_api.counter.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.counter.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "record_view" {
  api_id             = aws_apigatewayv2_api.counter.id
  route_key          = "POST /views"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.counter.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowCounterApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.counter.execution_arn}/*/POST/views"
}

resource "aws_apigatewayv2_stage" "counter" {
  api_id      = aws_apigatewayv2_api.counter.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 5
  }

  depends_on = [
    aws_apigatewayv2_route.record_view,
    aws_lambda_permission.api_gateway
  ]
}