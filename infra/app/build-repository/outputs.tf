output "image_registry" {
  value = module.container_image_repository.image_registry
}

output "image_repository_url" {
  value = module.container_image_repository.image_repository_url
}

output "region" {
  value = local.region
}
