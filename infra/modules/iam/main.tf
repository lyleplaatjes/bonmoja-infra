# Assume-role policy shared by both roles
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ---------- Execution role (for ECR pulls + CloudWatch Logs) ----------
resource "aws_iam_role" "ecs_exec" {
  name               = "${var.name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_managed" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------- Task role (app permissions) ----------
resource "aws_iam_role" "ecs_task" {
  name               = "${var.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "task_inline" {
  statement {
    sid       = "DynamoAccess"
    actions   = ["dynamodb:PutItem","dynamodb:GetItem","dynamodb:UpdateItem","dynamodb:Query"]
    resources = [var.dynamo_table_arn]
  }

  statement {
    sid       = "SQSAccess"
    actions   = ["sqs:SendMessage","sqs:ReceiveMessage","sqs:DeleteMessage","sqs:GetQueueAttributes"]
    resources = [var.sqs_queue_arn]
  }

  dynamic "statement" {
    for_each = var.allow_secrets ? [1] : []
    content {
      sid       = "SecretsAccess"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }
}

resource "aws_iam_policy" "task_policy" {
  name   = "${var.name}-ecs-task-policy"
  policy = data.aws_iam_policy_document.task_inline.json
}

resource "aws_iam_role_policy_attachment" "task_attach" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.task_policy.arn
}
