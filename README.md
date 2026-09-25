# OCX-ARCH-001: AWS Platform Reference

[![Validate Terraform reference](https://github.com/OpsChugex/terraform-aws-platform/actions/workflows/validate.yml/badge.svg)](https://github.com/OpsChugex/terraform-aws-platform/actions/workflows/validate.yml)

**Classification:** Reference implementation

**Default deployment state:** Disabled

This repository provides a safe-by-default Terraform reference for an AWS platform foundation. The configuration is real Terraform and is continuously validated, but no AWS resources are created unless `enable_reference_deployment` is deliberately changed from its default `false` value after architecture, security and cost review.

## Implemented reference controls

- VPC with DNS support
- two public and two private subnets across two availability zones
- internet gateway and explicit public routing
- no automatic public IP assignment on public subnets
- workload security group with no public ingress rule
- immutable ECR tags with image scanning on push
- private S3 evidence bucket with public-access blocking
- S3 versioning and server-side encryption
- CloudWatch log group with bounded retention
- consistent evidence and management tags

## Validation path

```text
architecture
  -> terraform fmt
  -> terraform init -backend=false
  -> terraform validate
  -> reviewed plan
  -> explicit cost approval
  -> controlled deployment
  -> health validation
  -> recorded evidence
```

The public workflow performs only the first three automated checks. It requires no AWS credentials and does not run `terraform apply`.

## Run locally

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## Safety boundary

Deployment remains opt-in:

```hcl
enable_reference_deployment = false
```

Changing that flag is not, by itself, an approval to deploy. A real deployment should use reviewed state storage, change approval, cost controls, identity boundaries and environment-specific policy.

## Limitations

This repository is not a customer environment and does not claim production availability, customer outcomes, recovery times or cost savings. It demonstrates an auditable infrastructure pattern and its validation controls.
