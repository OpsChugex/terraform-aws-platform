# OCX-ARCH-001: Production AWS Platform Reference

**Classification:** Reference implementation  
**Status:** Documented, no cloud resources deployed by this repository.

## Scope
A Terraform foundation for a VPC, public and private subnets, load balancing, container registry, Kubernetes, relational data, object storage and observability.

## Evidence path
Architecture → Terraform plan → CI validation → reviewed deployment → health checks → recorded result.

## Validation before deployment
- `terraform fmt -check`
- `terraform validate`
- policy and security review
- cost estimate
- approved change window

## Limitations
This is not a customer environment and does not claim production availability, recovery times or cost savings.