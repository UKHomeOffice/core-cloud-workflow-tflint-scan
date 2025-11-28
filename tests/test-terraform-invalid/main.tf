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

# Multiple issues that TFLint should catch:

# Issue 1: Deprecated syntax
resource "aws_instance" "deprecated_syntax" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  # Deprecated - should use vpc_security_group_ids
  security_groups = ["sg-12345"]
}

# Issue 2: Invalid instance type (AWS provider issue)
resource "aws_instance" "invalid_type" {
  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t1.2xlarge" # Invalid type - TFLint should catch this!
  
  tags = {
    Name = "invalid-instance"
  }
}

# Issue 3: Invalid instance type (another example)
resource "aws_instance" "another_invalid" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m5.undefined" # Invalid type
}

# Issue 4: Missing required argument
resource "aws_instance" "missing_ami" {
  instance_type = "t3.micro"
  # Missing required 'ami' argument - Terraform will catch this
}

# Issue 5: Invalid S3 bucket name
resource "aws_s3_bucket" "invalid_bucket_name" {
  bucket = "MyInvalidBucket_With_Uppercase" # S3 buckets must be lowercase
}