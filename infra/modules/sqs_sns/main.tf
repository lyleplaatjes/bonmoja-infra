resource "aws_sqs_queue" "dlq" {
  count = var.dlq_name == null ? 0 : 1
  name  = var.dlq_name
}

resource "aws_sqs_queue" "queue" {
  name = var.queue_name
  redrive_policy = var.dlq_name == null ? null : jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = 5
  })
}

resource "aws_sns_topic" "topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint = trimspace(var.email_endpoint)
}

output "queue_arn" { value = aws_sqs_queue.queue.arn }
output "topic_arn" { value = aws_sns_topic.topic.arn }
