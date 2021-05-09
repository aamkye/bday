terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.aws-profile
  region  = "eu-west-1"
  default_tags {
    tags = {
      Env = "bday"
    }
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}

resource "aws_s3_bucket" "state" {
  bucket = "ak95-terraform-state"
  acl    = "private"

  tags = {
    Name = "s3_tf_bucket"
  }
}
