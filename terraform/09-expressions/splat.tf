locals {
  first_names_from_splat       = var.objects_list[*].first_name
  roles_from_splat             = [for username, user_props in local.users_map2 : user_props.roles]
  roles_from_splat_with_values = values(local.users_map2)[*].roles
}

output "first_names_from_splat" {
  value = local.first_names_from_splat
}

output "roles_from_splat" {
  value = local.roles_from_splat
}