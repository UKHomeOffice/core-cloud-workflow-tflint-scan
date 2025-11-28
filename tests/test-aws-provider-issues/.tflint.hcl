plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enable specific AWS rules to catch provider issues
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_db_instance_invalid_type" {
  enabled = true
}