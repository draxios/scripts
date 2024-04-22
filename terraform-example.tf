terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "your-tfe-organization-name"
    
    workspaces {
      name = "your-tfe-workspace-name"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Update as necessary
}





resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  handler       = "index.handler"  # Update based on your actual handler in index.ts
  runtime       = "nodejs14.x"     # Check and update according to your Lambda's runtime

  s3_bucket = "your_lambda_code_bucket"
  s3_key    = "your_lambda_code_key.zip"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      EXAMPLE_VAR = "value"
    }
  }
}



resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "API Gateway for My Lambda Function"
}

resource "aws_api_gateway_resource" "my_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "my_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.my_api_resource.id
  http_method = aws_api_gateway_method.my_api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}



resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}
