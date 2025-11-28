terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Valid configuration - should pass TFLint
resource "aws_instance" "valid_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro" # Valid instance type

  tags = {
    Name        = "test-instance"
    Environment = "test"
  }
}

resource "aws_s3_bucket" "valid_bucket" {
  bucket = "my-test-bucket-12345-valid"

  tags = {
    Name        = "test-bucket"
    Environment = "test"
  }
}