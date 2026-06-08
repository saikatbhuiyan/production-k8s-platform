locals {
    project = "my-terraform-project"
    project_owner = "terraform-user"
    cost_center = "IT"
    managed_by = "Terraform"
}

locals {
  common_tags = {
    project       = local.project
    project_owner = local.project_owner
    cost_center   = local.cost_center
    managed_by    = local.managed_by
    sensitive_tag = var.my_sensitive_value
  }
}