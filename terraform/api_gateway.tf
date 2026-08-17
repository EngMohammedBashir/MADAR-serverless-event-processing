# ============================================================
# MADAR - API Gateway
# Public HTTP entry point for submitting jobs to the producer.
# ============================================================

# ------------------------------------------------------------
# HTTP API
# Provides the public endpoint clients use to submit jobs.
# ------------------------------------------------------------
resource "aws_apigatewayv2_api" "madar" {
  name          = "madar-api"
  protocol_type = "HTTP"
}

# ------------------------------------------------------------
# Lambda integration
# Forwards API requests directly to the producer Lambda.
# ------------------------------------------------------------
resource "aws_apigatewayv2_integration" "producer" {
  api_id = aws_apigatewayv2_api.madar.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.producer.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# ------------------------------------------------------------
# POST /jobs
# Clients submit new processing jobs through this route.
# ------------------------------------------------------------
resource "aws_apigatewayv2_route" "submit_job" {
  api_id = aws_apigatewayv2_api.madar.id

  route_key = "POST /jobs"
  target    = "integrations/${aws_apigatewayv2_integration.producer.id}"
}

# ------------------------------------------------------------
# Default stage
# Automatically deploys API changes without a separate stage.
# ------------------------------------------------------------
resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.madar.id

  name        = "$default"
  auto_deploy = true
}

# ------------------------------------------------------------
# Lambda permission
# Allows this API Gateway API to invoke the producer Lambda.
# ------------------------------------------------------------
resource "aws_lambda_permission" "api_gateway_producer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.producer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.madar.execution_arn}/*/*"
}
