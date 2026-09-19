terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}

provider "aws" { region = var.aws_region }

# Intentionally safe reference only. Resources stay disabled until
# enable_reference_deployment is explicitly set to true after cost approval.
module "platform" {
  count      = var.enable_reference_deployment ? 1 : 0
  source     = "./modules/platform"
  name       = var.name
  cidr_block = var.cidr_block
}