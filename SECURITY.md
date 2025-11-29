# Security Policy

## Overview
This repository forms part of the UK Home Office Core Cloud Platform’s shared GitHub Actions tooling. It contains a reusable TFLint workflow and a composite GitHub Action used across the platform to maintain Terraform linting and security standards.

Because of its purpose, the repository includes **intentionally invalid Terraform and Terragrunt code** for testing, validation, and demonstration.

This design requires specific security guidance, explained below.

## Why This Repository Contains Invalid Terraform

The directories:

* `tests/**`

* `examples/**`

contain Terraform or Terragrunt configurations that:

* violate TFLint rules

* use invalid instance types

* omit fields

* include deprecated patterns

These files are required to:

* validate the TFLint reusable workflow

* verify recursive scanning behaviour

* test custom .tflint.hcl configurations

* ensure broken IaC fails correctly

* provide example usage scenarios for downstream teams

These files **must not** be treated as real infrastructure definitions.

## SAST Exclusions

To prevent false positives and unnecessary CI pipeline failures, the following SAST tools are configured to ignore test fixtures and examples:

**Checkov** (`.checkov.yaml`)

```yaml
skip-path:
  - '^tests/.*'
  - '^examples/.*'

```

**SonarQube** (`sonar-project.properties`)
```
sonar.exclusions=tests/**,examples/**

```
These configurations ensure:

* Only the actual workflow logic and scripts are scanned

* Quality Gate failures reflect real issues, not test fixture content

* Checkov does not crash on intentionally malformed Terraform

* SARIF results remain meaningful

**Do Not Add Real IaC Under** `tests/**` or `examples/**`

Any production Terraform/Terragrunt code must not be added to these directories, because:

* It will be invisible to SAST

* It may be mistaken for intentionally broken IaC

* It will not be validated by the TFLint workflow

* It may mislead contributors and downstream teams

Real platform IaC belongs only inside repositories meant for Terraform or Terragrunt usage (e.g., module repos, environment repos).

## Reporting Security Issues

If you believe you have found a security vulnerability in:

* this workflow

* the composite action

* the test harness

* or any supporting scripts

please follow the internal vulnerability disclosure process and notify the Core Cloud Platform team privately through the approved internal channels (Slack / security contacts).

**Do not open GitHub Issues for security vulnerabilities**.

## Dependency Security

This repository does not use third-party Python, Go, or Node dependencies — only GitHub Actions and shell scripts.

Dependencies must satisfy:

* GitHub Enterprise action allow-lists

* Internal security requirements for workflows

* No hardcoded secrets

* Use of the repo-scoped `GITHUB_TOKEN` for authentication

## Security Summary

| Area                    | Policy                                               |
| ----------------------- | ---------------------------------------------------- |
| Test Terraform files    | Intentionally invalid & excluded from SAST           |
| Example IaC             | Excluded from SAST, for demonstration only           |
| Real IaC                | Not permitted in this repository                     |
| Secrets                 | Must use repo/org-encrypted secrets, never committed |
| Workflows               | Must use approved GitHub Actions only                |
| Vulnerability reporting | Private internal channels only                       |


