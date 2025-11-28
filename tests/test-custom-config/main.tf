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

# Test with stricter custom rules
resource "aws_instance" "custom_test" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  # This will trigger custom naming convention rules if enabled
  tags = {
    Name = "CustomTestInstance"
  }
}

resource "aws_s3_bucket" "custom_bucket" {
  bucket = "custom-test-bucket-12345"
  
  tags = {
    Name = "CustomBucket"
  }
}

# Variable without description (will trigger documentation rule)
variable "instance_count" {
  type = number
  default = 1
}

# Output without description (will trigger documentation rule)
output "instance_id" {
  value = aws_instance.custom_test.id
}