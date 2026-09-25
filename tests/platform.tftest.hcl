mock_provider "aws" {}

run "deployment_disabled_by_default" {
  command = plan

  assert {
    condition     = length(module.platform) == 0
    error_message = "Reference deployment must remain disabled by default."
  }
}

run "deployment_can_be_enabled_for_review" {
  command = plan

  variables {
    enable_reference_deployment = true
  }

  assert {
    condition     = length(module.platform) == 1
    error_message = "Enabling the reference should instantiate exactly one platform module."
  }
}
