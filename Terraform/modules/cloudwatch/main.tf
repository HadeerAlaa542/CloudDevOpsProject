resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "cpu-usage-${var.instance_id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    InstanceId = var.instance_id
  }
}