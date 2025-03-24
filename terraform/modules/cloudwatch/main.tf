resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/app"
  retention_in_days = 7
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.app_logs.name
}

