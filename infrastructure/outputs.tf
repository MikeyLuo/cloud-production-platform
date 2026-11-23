output "counter_table_name" {
  description = "DynamoDB table used by the page-view counter."
  value       = aws_dynamodb_table.page_views.name
}

output "counter_table_arn" {
  description = "Table ARN for the Lambda permissions policy."
  value       = aws_dynamodb_table.page_views.arn
}

output "counter_function_name" {
  description = "Lambda function that increments the page-view counter."
  value       = aws_lambda_function.counter.function_name
}

output "counter_log_group_name" {
  description = "CloudWatch log group for the counter."
  value       = aws_cloudwatch_log_group.counter.name
}