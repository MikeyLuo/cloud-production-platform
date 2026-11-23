locals {
  counter_function_name = "cloud-production-platform-counter"
}

resource "aws_cloudwatch_log_group" "counter" {
  name              = "/aws/lambda/${local.counter_function_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "counter" {
  name = "${local.counter_function_name}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "counter" {
  name = "counter-table-and-logs"
  role = aws_iam_role.counter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "IncrementCounter"
        Effect   = "Allow"
        Action   = "dynamodb:UpdateItem"
        Resource = aws_dynamodb_table.page_views.arn
      },
      {
        Sid    = "WriteFunctionLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.counter.arn}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "counter" {
  function_name = local.counter_function_name
  role          = aws_iam_role.counter.arn

  runtime       = "python3.13"
  handler       = "visitor_counter.lambda_handler"
  architectures = ["x86_64"]

  filename         = "${path.module}/../.build/visitor-counter.zip"
  source_code_hash = filebase64sha256("${path.module}/../.build/visitor-counter.zip")

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      COUNTER_TABLE_NAME = aws_dynamodb_table.page_views.name
    }
  }

  depends_on = [aws_iam_role_policy.counter]
}