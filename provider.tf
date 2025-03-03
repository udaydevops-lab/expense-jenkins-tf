terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket = "expense-prajai-bucket-dev"
    key    = "expense-jenkins"
    region = "us-east-1"
    dynamodb_table = "prajai-locking-table-dev"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}