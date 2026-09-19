variable "name" { type = string }
variable "cidr_block" { type = string }

# The module is intentionally empty until a reviewed AWS design, budget and
# production safeguards are approved. This keeps the reference non-destructive.
output "reference_name" { value = var.name }
output "reference_cidr" { value = var.cidr_block }