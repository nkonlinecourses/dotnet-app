output "acr_login_server" {
  description = "Login server URL of the Azure Container Registry."
  value       = module.acr.login_server
}

output "aks_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.name
}

output "key_vault_id" {
  value = module.key_vault.id
}

output "private_endpoint_subnet_id" {
  value = module.network.private_endpoint_subnet_id
}
