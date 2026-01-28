# Core Cloud TFLint Reusable Workflow

A reusable GitHub Actions composite action for running TFLint security and linting checks across Terraform and Terragrunt repositories.

## Features

- ✅ **Universal Support**: Works with Terraform, Terraform Modules, and Terragrunt repos
- ✅ **Flexible Configuration**: Use default configs or bring your own
- ✅ **Plugin Caching**: Faster workflow runs with automatic plugin caching
- ✅ **Recursive Scanning**: Scan entire repository structures
- ✅ **Multiple Output Formats**: Compact, JSON, SARIF, and more
- ✅ **AWS Best Practices**: Built-in AWS ruleset for cloud security

> **Note**: For tag enforcement, please use the [Checkov workflow](https://github.com/UKHomeOffice/core-cloud-workflow-checkov-sast-scan) which is the standard tool for tag compliance checking.

## Checkout behavior

By default, this composite action **does not checkout the repository**.

This follows GitHub Actions best practice:  
the **caller workflow** is responsible for checking out the code it wants to scan.

## Usage

### Typical usage (recommended)

Use the reusable TFLint workflow. This is the preferred approach for most repositories:

```yaml
jobs:
  tflint-scan:
    uses: UKHomeOffice/core-cloud-workflow-tflint-scan/.github/workflows/tflint.yaml@v0.1.0
```

Optionally add inputs:

```yaml
jobs:
  tflint-scan:
    uses: UKHomeOffice/core-cloud-workflow-tflint-scan/.github/workflows/tflint.yaml@v0.1.0
    with:
      working_directory: .
      tflint_recursive: true
```

### Basic Usage (Terraform Modules)
```yaml
name: TFLint Validation

on:
  pull_request:
    branches:
      - main

jobs:
  tflint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run TFLint
        uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v0.1.0
        with:
          tflint_recursive: true
```

### Terragrunt Repository
```yaml
steps:
  - uses: actions/checkout@v4

  - name: Run TFLint on Terragrunt
    uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v0.1.0
    with:
      working_directory: '.'
      tflint_recursive: true
```

### With Custom Configuration
```yaml
- name: Run TFLint with Custom Config
  uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v1
  with:
    custom_config_path: '.tflint.hcl'
    tflint_recursive: true
```

### Specific Directory
```yaml
- name: Scan Specific Module
  uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v1
  with:
    working_directory: 'modules/aws/vpc'
    tflint_recursive: false
```

## Composite action usage (advanced)
### Composite action when checkout is handled by the caller (recommended)

Use this when you want to embed TFLint into an existing job
that already checks out the repository:

```yaml
steps:
  - uses: actions/checkout@v4

  - name: TFLint Scan
    uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v0.1.0
    with:
      checkout: false
```


## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `working_directory` | Directory to run TFLint in | No | `.` |
| `tflint_version` | TFLint version | No | `v0.54.0` |
| `tflint_recursive` | Run recursively | No | `true` |
| `custom_config_path` | Path to custom .tflint.hcl | No | `''` |
| `fail_on_error` | Fail workflow on errors | No | `true` |
| `aws_plugin_version` | AWS plugin version | No | `0.40.0` |
| `terraform_plugin_preset` | Terraform plugin preset | No | `recommended` |
| `output_format` | Output format | No | `compact` |
| `github_token` | GitHub token | No | `GITHUB_TOKEN` |

## Outputs

| Output | Description |
|--------|-------------|
| `tflint_exit_code` | Exit code from TFLint (0 = success) |
| `tflint_result` | Result status (success/failure) |

## Default Configuration

When no custom config is provided, the action uses:
```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
```

## Custom Configuration

To use your own TFLint rules, create a `.tflint.hcl` in your repository:
```hcl
plugin "terraform" {
  enabled = true
  preset  = "all"  # More strict than "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Add custom rules
rule "terraform_naming_convention" {
  enabled = true
}
```

Then reference it:
```yaml
- uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v1
  with:
    custom_config_path: '.tflint.hcl'
```

## Migration from Marketplace Actions

If you're currently using `terraform-linters/setup-tflint` directly:

**Before:**
```yaml
- uses: actions/checkout@v4
- uses: terraform-linters/setup-tflint@v2
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
- run: tflint --init
- run: tflint --recursive
```

**After:**
```yaml
- uses: actions/checkout@v4
- uses: UKHomeOffice/core-cloud-workflow-tflint-scan@v1
  with:
    tflint_recursive: true
```

## Terraform vs. Terragrunt

This workflow works seamlessly with both:

- **Terraform Modules Repos**: Validates `.tf` files and module configurations
- **Terragrunt Repos**: Validates both `.hcl` (Terragrunt) and underlying `.tf` files

No special configuration needed - the workflow auto-detects and handles both.

## Tag Enforcement

**Important**: Tag enforcement should be handled by the [Checkov workflow](https://github.com/UKHomeOffice/core-cloud-workflow-checkov-sast-scan), which is the platform's standard tool for tag compliance checking.

TFLint focuses on:
- Terraform syntax and best practices
- AWS resource configuration validation
- Security and compliance checks (non-tag related)
- Deprecated syntax detection

## Examples

See the [`examples/`](./examples/) directory for complete usage examples:

- `terraform-modules-usage.yml` - For Terraform module repositories
- `terragrunt-usage.yml` - For Terragrunt repositories
- `custom-config-usage.yml` - Using custom TFLint configurations
- `specific-directory-usage.yml` - Scanning specific directories

## Troubleshooting

### Plugin Download Failures

If plugins fail to download, ensure your `github_token` has appropriate permissions.

### Custom Config Not Found

Ensure `custom_config_path` is relative to repository root (e.g., `.tflint.hcl` or `config/.tflint.hcl`).

### Recursive Scan Issues

If recursive scanning causes issues, set `tflint_recursive: false` and specify `working_directory` for targeted scans.

## What TFLint Checks

TFLint validates:
- ✅ Terraform syntax errors
- ✅ Deprecated Terraform syntax
- ✅ AWS resource misconfigurations
- ✅ Best practice violations
- ✅ Security issues (non-tag related)
- ✅ Provider-specific rules

## Support

For issues or questions:
- Create an issue in this repository
- Contact the Sauron Team on Slack: #core-cloud-team-sauron
- For tag enforcement questions, contact the Checkov workflow maintainers: #core-cloud-team-sauron

## Related Workflows

- [Checkov SAST Scan](https://github.com/UKHomeOffice/core-cloud-workflow-checkov-sast-scan) - For tag enforcement and policy-as-code
- [Sonarqube Scan](https://github.com/UKHomeOffice/core-cloud-workflow-sonarqube-scan) - For code quality analysis


---

## Updated Repository Structure
```
core-cloud-workflow-tflint-scan/
.github
└── workflows
|    ├── self-test.yaml
|   └── tflint.yaml
|
├── action.yaml
├── CODEOWNERS
├── configs
├── examples
│   ├── custom-config-usage.yaml
│   ├── specific-directory-usage.yaml
│   ├── terraform-modules-usage.yaml
│   └── terragrunt-usage.yaml
├── README.md
└── tests
    ├── README.md
    ├── run-local-tests.sh
    ├── test-aws-provider-issues
    │   └── main.tf
    ├── test-custom-config
    │   └── main.tf
    ├── test-terraform-invalid
    │   └── main.tf
    ├── test-terraform-valid
    │   └── main.tf
    └── test-terragrunt
        ├── main.tf
        └── terragrunt.hcl

```
## 🔒 SAST Configuration (Checkov & SonarQube)

This repository includes intentionally invalid Terraform and Terragrunt code under `tests/**` and `examples/**` for validating the reusable TFLint workflow. These directories must not be scanned by SAST tools, as they will always contain failing content by design.

To ensure accurate SAST reporting, the following configuration files are used:

### 🛡️ Checkov Configuration 
– `.checkov.yaml`

```yaml
skip-path:
  # All TFLint test fixtures (intentionally invalid Terraform configurations)
  - '^tests/.*'
  # Example usage directories (intentionally invalid Terraform configurations)
  - '^examples/.*'

```
This prevents Checkov from scanning directories containing intentionally broken code, avoiding false positives and SARIF upload failures.

### 📘 SonarQube Configuration 
– `sonar-project.properties`

```
sonar.exclusions=tests/**,examples/**

```
This removes all test fixtures and example IaC from SonarQube analysis, ensuring the Quality Gate only evaluates the actual workflow, action code, and scripts.

| Directory           | Purpose                                               | Excluded From SAST? |
| ------------------- | ----------------------------------------------------- | ------------------- |
| `tests/**`          | Local TFLint test harness (intentionally invalid IaC) | ✅ Yes               |
| `examples/**`       | Usage examples for the reusable workflow              | ✅ Yes               |
| `.github/workflows` | Workflow definitions                                  | ❌ No                |
| `action.yaml`       | Composite action logic                                | ❌ No                |
| `tflint.yaml`       | Reusable workflow                                     | ❌ No                |

This setup ensures clean SAST results without blocking PRs due to intentionally invalid IaC.
