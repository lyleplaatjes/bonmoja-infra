terraform {
    required_version = ">= 1.5.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {} # details in backend.tf
}

provider "aws" {
    region = var.aws_region
}

resource "aws_s3_bucket" "test" {
    bucket = "${var.env}-bonmoja-test-${random_id.rand.hex}"
}

resource "random_id" "rand" {
    byte_length = 2
}