module "secrets" {
  for_each = local.service_config.secrets

  source = "../../modules/secret"

  # When generating secrets and storing them in parameter store, append the
  # terraform workspace to the secret store path if the environment is temporary
  # to avoid conflicts with existing environments.
  # Don't do this for secrets that are managed manually since the temporary
  # environments will need to share those secrets.
  secret_store_path = (each.value.manage_method == "code" && local.is_temporary ?
    "${each.value.secret_store_path}/${terraform.workspace}" :
    each.value.secret_store_path
  )
  manage_method = each.value.manage_method
}
