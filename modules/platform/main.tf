terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "enabled" {
  type        = bool
  default     = false
  description = "Creates reference resources only when explicitly enabled."
}

variable "name" {
  type = string

  validation {
    condition     = length(trimspace(var.name)) >= 3
    error_message = "name must contain at least three characters."
  }
}

variable "cidr_block" {
  type = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

locals {
  common_tags = {
    ManagedBy      = "Terraform"
    EvidenceId     = "OCX-ARCH-001"
    Classification = "ReferenceImplementation"
  }

  public_subnets = {
    public-a = cidrsubnet(var.cidr_block, 4, 0)
    public-b = cidrsubnet(var.cidr_block, 4, 1)
  }

  private_subnets = {
    private-a = cidrsubnet(var.cidr_block, 4, 8)
    private-b = cidrsubnet(var.cidr_block, 4, 9)
  }
}

resource "aws_vpc" "this" {
  count                = var.enabled ? 1 : 0
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = var.name })
}

resource "aws_subnet" "public" {
  for_each = var.enabled ? local.public_subnets : {}

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${var.name}-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = var.enabled ? local.private_subnets : {}

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${var.name}-${each.key}"
    Tier = "private"
  })
}

resource "aws_internet_gateway" "this" {
  count  = var.enabled ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(local.common_tags, { Name = "${var.name}-igw" })
}

resource "aws_route_table" "public" {
  count  = var.enabled ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(local.common_tags, { Name = "${var.name}-public" })
}

resource "aws_route" "internet" {
  count                  = var.enabled ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each       = var.enabled ? aws_subnet.public : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_security_group" "application" {
  count       = var.enabled ? 1 : 0
  name_prefix = "${var.name}-app-"
  description = "Reference application security group"
  vpc_id      = aws_vpc.this[0].id

  egress {
    description = "Outbound HTTPS only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name}-app" })
}

resource "aws_ecr_repository" "application" {
  count                = var.enabled ? 1 : 0
  name                 = "${var.name}-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "platform" {
  count             = var.enabled ? 1 : 0
  name              = "/opschugex/reference/${var.name}"
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_s3_bucket" "evidence" {
  count  = var.enabled ? 1 : 0
  bucket = null
  tags   = merge(local.common_tags, { Purpose = "EvidenceStorage" })
}

resource "aws_s3_bucket_public_access_block" "evidence" {
  count                   = var.enabled ? 1 : 0
  bucket                  = aws_s3_bucket.evidence[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "summary" {
  value = {
    enabled               = var.enabled
    vpc_count             = length(aws_vpc.this)
    public_subnet_count   = length(aws_subnet.public)
    private_subnet_count  = length(aws_subnet.private)
    ecr_count             = length(aws_ecr_repository.application)
    log_group_count       = length(aws_cloudwatch_log_group.platform)
    evidence_bucket_count = length(aws_s3_bucket.evidence)
  }
}
