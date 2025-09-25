# --- RDS CPU > 80% for 5 minutes ---
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5               # 5 x 60s = 5 minutes
  period              = 60
  threshold           = 80
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = module.rds.identifier  # ensure your RDS module outputs this
  }

  alarm_description = "RDS CPU > 80% for 5 minutes"
  alarm_actions     = [module.sqs_sns.topic_arn]
  ok_actions        = [module.sqs_sns.topic_arn]
}

# --- SQS queue depth > 100 messages for 10 minutes ---
resource "aws_cloudwatch_metric_alarm" "sqs_backlog_high" {
  alarm_name          = "${local.name}-sqs-backlog-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10              # 10 x 60s = 10 minutes
  period              = 60
  threshold           = 100
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = module.sqs_sns.queue_name
  }

  alarm_description = "SQS visible messages >= 100 for 10 minutes"
  alarm_actions     = [module.sqs_sns.topic_arn]
  ok_actions        = [module.sqs_sns.topic_arn]
}
