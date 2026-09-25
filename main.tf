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

# Safe by default: the reference module is parsed and validated but no AWS
# resources exist unless deployment is explicitly enabled after review.
module "platform" {
  count      = var.enable_reference_deployment ? 1 : 0
  source     = "./modules/platform"
  name       = var.name
  cidr_block = var.cidr_block
  aws_region = var.aws_region
}
