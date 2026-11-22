output "counter_table_name" {
  description = "DynamoDB table used by the page-view counter."
  value       = aws_dynamodb_table.page_views.name
}

output "counter_table_arn" {
  description = "Table ARN for the Lambda permissions policy."
  value       = aws_dynamodb_table.page_views.arn
}