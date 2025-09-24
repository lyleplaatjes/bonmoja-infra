terraform {
  backend "s3" {
    bucket         = "bonmoja-terraform-state-670278274130"
    key            = "staging/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
