# Simple Terraform file to test alongside Terragrunt
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

resource "aws_instance" "terragrunt_test" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name        = "terragrunt-test"
    Environment = "test"
  }
}

resource "aws_s3_bucket" "terragrunt_bucket" {
  bucket = "terragrunt-test-bucket-12345"
  
  tags = {
    Name        = "terragrunt-bucket"
    Environment = "test"
  }
}