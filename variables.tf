variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "name" {
  type    = string
  default = "opschugex-reference"
}

variable "cidr_block" {
  type    = string
  default = "10.42.0.0/16"
}
variable "enable_reference_deployment" {
  type = bool
  default = false
  description = "Requires cost approval and a reviewed Terraform plan."
}