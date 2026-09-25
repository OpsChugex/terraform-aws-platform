mock_provider "aws" {}

run "safe_default" {
  command = plan

  variables {
    enabled    = false
    name       = "opschugex-reference"
    cidr_block = "10.42.0.0/16"
  }

  assert {
    condition     = output.summary.vpc_count == 0
    error_message = "The module must create no VPC when enabled=false."
  }
}

run "reference_shape" {
  command = plan

  variables {
    enabled    = true
    name       = "opschugex-reference"
    cidr_block = "10.42.0.0/16"
  }

  assert {
    condition     = output.summary.vpc_count == 1
    error_message = "The enabled reference must contain one VPC."
  }

  assert {
    condition     = output.summary.public_subnet_count == 2 && output.summary.private_subnet_count == 2
    error_message = "The reference must contain two public and two private subnets."
  }

  assert {
    condition     = output.summary.ecr_count == 1 && output.summary.log_group_count == 1 && output.summary.evidence_bucket_count == 1
    error_message = "Registry, log group and evidence bucket must be represented."
  }
}
