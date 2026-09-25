variable "aws_region" {
  type        = string
  default     = "ca-central-1"
  description = "AWS region used only if a reviewed deployment is explicitly enabled."
}

variable "name" {
  type        = string
  default     = "opschugex-reference"
  description = "Prefix used by the reference architecture."
}

variable "cidr_block" {
  type        = string
  default     = "10.42.0.0/16"
  description = "VPC CIDR used by the reference architecture."

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "enable_reference_deployment" {
  type        = bool
  default     = false
  description = "Safety gate. Validation and tests never require this to be true against AWS."
}
