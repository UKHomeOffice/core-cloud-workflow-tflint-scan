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

# THIS IS THE KEY TEST - Issues that terraform validate CANNOT catch!
# These fixtures intentionally contain insecure configurations so that
# TFLint's AWS provider rules are exercised. These resources must NEVER
# be used in production. All Checkov findings are intentionally skipped.


# -------------------------------------------------------------------------
# Test Case 1: Invalid instance type (key TFLint test)
# -------------------------------------------------------------------------
resource "aws_instance" "foo" {
  # checkov:skip=CKV_AWS_8: EBS encryption intentionally disabled for test
  # checkov:skip=CKV_AWS_79: IMDSv1 intentionally enabled to trigger checks
  # checkov:skip=CKV_AWS_126: Detailed monitoring intentionally disabled
  # checkov:skip=CKV_AWS_135: EBS optimization intentionally disabled

  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t1.2xlarge" # Invalid type! terraform validate won't catch this
  
  tags = {
    Name = "test-invalid-t1-2xlarge"
  }
}


# -------------------------------------------------------------------------
# Test Case 2: Invalid instance type (different value)
# -------------------------------------------------------------------------
resource "aws_instance" "invalid_instance_type_2" {
  # checkov:skip=CKV_AWS_8: EBS encryption intentionally disabled for test
  # checkov:skip=CKV_AWS_79: IMDSv1 intentionally enabled to trigger checks
  # checkov:skip=CKV_AWS_126: Detailed monitoring intentionally disabled
  # checkov:skip=CKV_AWS_135: EBS optimization intentionally disabled

  ami           = "ami-0ff8a91507f77f867"
  instance_type = "m5.32xlarge" # Invalid - max is 24xlarge for m5
  
  tags = {
    Name = "test-invalid-m5-32xlarge"
  }
}


# -------------------------------------------------------------------------
# Test Case 3: Fully fake instance type
# -------------------------------------------------------------------------
resource "aws_instance" "invalid_instance_type_3" {
  # checkov:skip=CKV_AWS_8: EBS encryption intentionally disabled for test
  # checkov:skip=CKV_AWS_79: IMDSv1 intentionally enabled to trigger checks
  # checkov:skip=CKV_AWS_126: Detailed monitoring intentionally disabled
  # checkov:skip=CKV_AWS_135: EBS optimization intentionally disabled

  ami           = "ami-0ff8a91507f77f867"
  instance_type = "c5.fake" # Invalid - completely made up
  
  tags = {
    Name = "test-invalid-c5-fake"
  }
}


# -------------------------------------------------------------------------
# Test Case 4: Invalid EBS volume type
# -------------------------------------------------------------------------
resource "aws_ebs_volume" "invalid_volume_type" {
  # checkov:skip=CKV_AWS_8: Encryption intentionally disabled for negative test

  availability_zone = "eu-west-2a"
  size              = 40
  type              = "gp99" # Invalid - should be gp2, gp3, io1, io2, st1, or sc1
  
  tags = {
    Name = "test-invalid-volume"
  }
}


# -------------------------------------------------------------------------
# Test Case 5: Invalid RDS instance class
# -------------------------------------------------------------------------
resource "aws_db_instance" "invalid_db_class" {
  # checkov:skip=CKV_AWS_129: Storage encryption intentionally disabled for test
  # (Note: Checkov may not flag this exact ID depending on engine, but adding anyway)

  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.undefined" # Invalid instance class
  username             = "admin"
  password             = "password123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  
  tags = {
    Name = "test-invalid-db"
  }
}
