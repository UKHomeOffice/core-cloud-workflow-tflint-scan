# TFLint Workflow Local Testing

This directory contains test cases for validating the TFLint composite action locally before deployment.

## Prerequisites

Install TFLint locally:
```bash
# macOS
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Windows (with Chocolatey)
choco install tflint
```

Verify installation:
```bash
tflint --version
```

## Running Tests Locally

### Run All Tests
```bash
cd tests
./run-local-tests.sh
```

### Run Individual Tests
```bash
cd tests/test-aws-provider-issues
tflint --init
tflint --format=compact --recursive
```

## Test Cases

### 1. Valid Terraform Configuration (`test-terraform-valid/`)
- **Purpose**: Verify TFLint passes on correctly formatted Terraform
- **Expected Result**: ✅ Pass (exit code 0)
- **Tests**:
  - Valid AWS instance configuration
  - Valid S3 bucket configuration
  - Proper tagging

### 2. Invalid Terraform Configuration (`test-terraform-invalid/`)
- **Purpose**: Verify TFLint catches common Terraform issues
- **Expected Result**: ❌ Fail (exit code > 0)
- **Tests**:
  - Deprecated syntax usage
  - Missing required arguments
  - Invalid resource configurations

### 3. AWS Provider-Specific Issues (`test-aws-provider-issues/`)
- **Purpose**: Verify TFLint catches AWS provider issues that `terraform validate` misses
- **Expected Result**: ❌ Fail (exit code > 0)
- **Tests**:
  - Invalid EC2 instance types (e.g., `t1.2xlarge`, `m5.32xlarge`)
  - Invalid EBS volume types (e.g., `gp99`)
  - Invalid RDS instance classes
  - **This is the key test case** - these errors won't be caught by `terraform validate`!

### 4. Terragrunt Configuration (`test-terragrunt/`)
- **Purpose**: Verify TFLint works with Terragrunt repos
- **Expected Result**: ✅ Pass (exit code 0)
- **Tests**:
  - Terragrunt HCL parsing
  - Mixed Terraform + Terragrunt files

### 5. Custom Configuration (`test-custom-config/`)
- **Purpose**: Verify custom `.tflint.hcl` configurations work (strict rules)
- **Expected Result**: ❌ Fail (exit code > 0)
- **Tests**:
  - Stricter rule enforcement (`preset = "all"`)
  - Custom naming / module structure rules
  - Documentation requirements (variables/outputs descriptions)

## Manual Testing Individual Cases

### Test the Invalid Instance Type Issue

**Purpose**: Verify TFLint catches AWS provider issues that `terraform validate` misses
```bash
cd tests/test-aws-provider-issues

# Initialize TFLint
tflint --init

# Run TFLint - should catch t1.2xlarge as invalid
tflint --format=compact

# Compare with terraform validate (won't catch the issue)
terraform init
terraform validate  # This will pass!
```

**Expected Output:**
```bash
tflint --format=compact --recursive
7 issue(s) found:

main.tf:67:26: Notice - "default.mysql5.7" is default parameter group. You cannot edit it. (aws_db_instance_default_parameter_group)
main.tf:64:26: Error - "db.t2.undefined" is invalid instance type. (aws_db_instance_invalid_type)
main.tf:21:19: Warning - "t1.2xlarge" is previous generation instance type. (aws_instance_previous_type)
main.tf:52:23: Error - "gp99" is an invalid value as type (aws_ebs_volume_invalid_type)
main.tf:21:19: Error - "t1.2xlarge" is an invalid value as instance_type (aws_instance_invalid_type)
main.tf:31:19: Error - "m5.32xlarge" is an invalid value as instance_type (aws_instance_invalid_type)
main.tf:41:19: Error - "c5.fake" is an invalid value as instance_type (aws_instance_invalid_type)
❯ echo $?
2
```

### Test Specific Directory
```bash
cd tests/test-terraform-valid
tflint --init --config=.tflint.hcl
tflint --format=compact --config=.tflint.hcl
```

### Test Recursive Scanning
```bash
cd tests
tflint --init --recursive
tflint --format=compact --recursive
```

## Debugging Failed Tests

If a test fails unexpectedly:

1. **Check TFLint version**:
```bash
   tflint --version
```

2. **Run with verbose output**:
```bash
   tflint --format=compact --loglevel=debug
```

3. **Verify plugin installation**:
```bash
   ls -la ~/.tflint.d/plugins
```

4. **Re-initialize plugins**:
```bash
   rm -rf ~/.tflint.d/plugins
   tflint --init
```

## Comparing with Terraform Validate

To demonstrate TFLint's value:
```bash
cd tests/test-aws-provider-issues

# Terraform validate won't catch invalid instance types
terraform init
terraform validate
echo "Exit code: $?"  # Will be 0 (success)

# But TFLint will catch them
tflint --init
tflint --format=compact
echo "Exit code: $?"  # Will be non-zero (failure)
```

## Expected Outputs

### Valid Configuration (Should Pass)
```
✅ No issues found
```

```bash
❯ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
❯ terraform validate
Success! The configuration is valid.

❯ echo $?
0
```

### Invalid Instance Type (Should Fail)
```bash
❌ Error: "t1.2xlarge" is an invalid value as instance_type (aws_instance_invalid_type)
  on main.tf line 14:
  14:   instance_type = "t1.2xlarge"
```

```bash
main.tf:21:19: Warning - "t1.2xlarge" is previous generation instance type. (aws_instance_previous_type)
❯ echo $?
2
```

## Adding New Tests

1. Create a new directory under `tests/test-<name>/`
2. Add Terraform files with test cases
3. Add `.tflint.hcl` configuration
4. Update `run-local-tests.sh` to include the new test
5. Document the test case in this README

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `tflint: command not found` | Install TFLint (see Prerequisites) |
| Plugin download fails | Check internet connection, try `tflint --init` again |
| Tests hang | Check for syntax errors in `.tf` files |
| False positives | Review `.tflint.hcl` rules, adjust as needed |

## Additional Resources

- [TFLint Documentation](https://github.com/terraform-linters/tflint)
- [TFLint AWS Ruleset](https://github.com/terraform-linters/tflint-ruleset-aws)
- [TFLint Rules Reference](https://github.com/terraform-linters/tflint/tree/master/docs/rules)