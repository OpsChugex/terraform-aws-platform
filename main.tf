terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "platform" {
  source     = "./modules/platform"
  enabled    = var.enable_reference_deployment
  name       = var.name
  cidr_block = var.cidr_block
}

output "reference_deployment_enabled" {
  value = var.enable_reference_deployment
}

output "platform_summary" {
  value = module.platform.summary
}
