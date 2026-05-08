provider "aws" {
  region = "us-east-1"
}

#permissions to execute
# This is AWS identity access management:
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#Adds Lambda Logging Permissions
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#aws_lambda_function Deploys my Python code
resource "aws_lambda_function" "demo_lambda" {
  function_name = "demo-serverless-function"

  filename      = "lambda_function.zip"
  handler       = "lambda_function.lambda_handler"

  runtime = "python3.11"

  role = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda_function.zip")
}

#Creates public HTTP endpoint
#Equivalent to web server frontend, request router
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "serverless-http-api"
  protocol_type = "HTTP"

##added to allow Cross-Origin Resource Sharing (Browser 
#   security blocks this by default)
#Different domains = browser blocks requests unless 
#   API explicitly allows them
  cors_configuration {
    allow_origins = ["*"]#which websites can call API
    #in prod normally allow_origins restricted to what we want, 
    # but for demo "*" makes it easier to get running.

    allow_methods = ["GET"]#allowed HTTP methods

    allow_headers = ["*"]#allowed request headers
  }
}

#Connects API Gateway to Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  #AWS_PROXY forwards the full HTTP request directly to Lambda
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.demo_lambda.invoke_arn
  payload_format_version = "2.0"
}

#defines default http path
resource "aws_apigatewayv2_route" "default_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  route_key = "GET /"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

#Deploys API publicly
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  name        = "$default"
  auto_deploy = true
}

#Allows API Gateway to invoke Lambda
#Without this: API fails with permissions error
resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowExecutionFromAPIGateway"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.demo_lambda.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

output "api_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}

#S3-----------------

#Creates cloud storage bucket.
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "dan-multicloud-serverless-demo"
}

#turns s3 into a static website host
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }
}

#Allows public internet access
resource "aws_s3_bucket_public_access_block" "frontend_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#Makes files publicly readable.
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}

#uploads my html file to the bucket
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

output "frontend_url" {
  value = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}