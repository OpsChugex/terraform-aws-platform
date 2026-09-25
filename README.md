# OCX-ARCH-001: AWS Platform Reference

[![Validate Terraform reference](https://github.com/OpsChugex/terraform-aws-platform/actions/workflows/validate.yml/badge.svg)](https://github.com/OpsChugex/terraform-aws-platform/actions/workflows/validate.yml)

**Classification:** Reference implementation

**Default deployment state:** Disabled

This repository provides a reviewable Terraform reference for an AWS platform foundation. The current implementation models:

- one VPC with DNS support
- two public subnets
- two private subnets
- public internet gateway and route table
- application security group with restricted outbound HTTPS
- immutable ECR repository with scan-on-push
- CloudWatch log group with defined retention
- S3 evidence storage with public access blocked

## Zero-cost safety gate

`enable_reference_deployment` defaults to `false`. The validation workflow does not run `terraform apply`, does not require AWS credentials and does not create AWS resources.

The module is tested with Terraform's mock-provider capability. That allows the enabled architecture shape to be planned and asserted without contacting AWS.

## Evidence path

**architecture → Terraform code → formatting → initialization → validation → mock-provider plan tests → reviewed deployment only if separately approved**

## Validate locally

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform -chdir=modules/platform init -backend=false
terraform -chdir=modules/platform validate
terraform -chdir=modules/platform test
```

## What the tests prove

The automated tests verify both sides of the safety model:

1. With deployment disabled, zero VPC resources are planned.
2. With the mock provider and deployment enabled for test purposes, the reference contains the expected VPC, subnet, registry, logging and evidence-storage shape.

## Limitations

This is not a customer environment and does not claim production availability, recovery times, cost savings or compliance certification. A real deployment would require architecture review, cost approval, account-specific IAM design, state/backend controls, change approval and post-deployment validation.
