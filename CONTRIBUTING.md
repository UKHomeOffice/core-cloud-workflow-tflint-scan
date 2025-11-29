# Contribution guide

Contributing to `core-cloud-workflow-tflint-scan`

This repository is part of the UK Home Office Core Cloud Platform shared tooling ecosystem.
To maintain consistent security and operational standards, all contributions must follow the guidelines below.

## Repository Structure & Source of Truth

This repository contains:

* `action.yaml` — composite GitHub Action for running TFLint

* `.github/workflows/tflint.yaml` — reusable workflow

* `tests/**` — intentionally invalid Terraform/Terragrunt test fixtures

* `examples/**` — usage examples for downstream repos

* `.checkov.yaml` & `sonar-project.properties` — SAST configuration

* Supporting documentation and helper scripts

Please familiarise yourself with this structure before making changes.

## SAST & Security Requirements
This repository is continuously scanned by:

* Checkov (via `checkov-scan-base.yaml`)

* SonarQube (via `sonarqube-scan.yaml`)

To avoid false positives and pipeline failures, **do not place production IaC under these directories**:

* tests/**

* examples/**

These directories contain intentionally broken Terraform designed solely for:

* TFLint regression tests

* TFLint behaviour validation

* Example usage patterns for downstream repositories

They are excluded from all SAST tools via:

* .checkov.yaml

* sonar-project.properties

If you add real IaC here, it will be ignored by SAST and may mislead users.

## Adding / Updating Test Fixtures
The tests/** directory is for:

* Invalid Terraform (to ensure failures surface correctly)

* Valid Terraform (to ensure passes work correctly)

* Terragrunt examples

* Custom configuration behaviours

When adding tests:

1. Never commit real platform modules or resources.

2. Keep all test cases isolated inside their own folder.

3. Add a .tflint.hcl file to each test directory.

4. Update the test script at tests/run-local-tests.sh if you add a new test case.

## Development Workflow

1. Create a feature branch

```
feature/<JIRA-ID>-<short-description>

```
2. Run tests locally

```bash
cd tests
./run-local-tests.sh

```

3. Open a Pull Request

All PRs must go through:

* Checkov scan

* SonarQube analysis

* SemVer label check

* Self-Test workflow for TFLint

* Manual reviewer approval

4. SemVer labelling

Each PR must include exactly one of:

* major

* minor

* patch

* (or skip-release)

Labels are validated automatically by workflow `Check PR for SemVer Label`.

## Coding Standards

* All bash scripts must run in `set -e` mode unless justified.

* Use idiomatic GitHub Actions patterns.

* Prefer enterprise-approved actions (see `.github/workflows/self-test.yaml` for allowed list).

* Composite action logic must remain POSIX-portable.

## Getting Help

For questions, reach out via:

* #core-cloud-sauron

* Reviewers listed in `CODEOWNERS`