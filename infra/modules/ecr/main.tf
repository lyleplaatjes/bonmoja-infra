resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
     scan_on_push = true 
     }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Keep last 20 images",
      selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 20 },
      action    = { type = "expire" }
    }]
  })
}
