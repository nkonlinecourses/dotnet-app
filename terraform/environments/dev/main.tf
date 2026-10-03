module "rg" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source = "../../modules/network"

  vnet_name                    = var.vnet_name
  location                     = module.rg.location
  resource_group_name          = module.rg.name
  vnet_cidr                    = var.vnet_cidr
  aks_subnet_cidr              = var.aks_subnet_cidr
  private_endpoint_subnet_cidr = var.private_endpoint_subnet_cidr
}

module "acr" {
  source = "../../modules/acr"

  name                = var.acr_name
  resource_group_name = module.rg.name
  location            = module.rg.location
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                = "law-${var.aks_name}"
  resource_group_name = module.rg.name
  location            = module.rg.location
  aks_cluster_name    = var.aks_name
}

module "aks" {
  source = "../../modules/aks"

  name                                = var.aks_name
  resource_group_name                 = module.rg.name
  location                            = module.rg.location
  subnet_id                           = module.network.aks_subnet_id
  acr_id                              = module.acr.id
  log_analytics_workspace_resource_id = module.monitoring.workspace_resource_id
  node_count                          = var.node_count
  vm_size                             = var.vm_size
}


data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = var.key_vault_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

module "acr_private_endpoint" {
  source = "../../modules/private-endpoint"

  name                           = "pe-${var.acr_name}"
  location                       = module.rg.location
  resource_group_name            = module.rg.name
  subnet_id                      = module.network.private_endpoint_subnet_id
  virtual_network_id             = module.network.vnet_id
  private_connection_resource_id = module.acr.id
  private_dns_zone_name          = "privatelink.azurecr.io"
  subresource_names              = ["registry"]
}

module "key_vault_private_endpoint" {
  source = "../../modules/private-endpoint"

  name                           = "pe-${var.key_vault_name}"
  location                       = module.rg.location
  resource_group_name            = module.rg.name
  subnet_id                      = module.network.private_endpoint_subnet_id
  virtual_network_id             = module.network.vnet_id
  private_connection_resource_id = module.key_vault.id
  private_dns_zone_name          = "privatelink.vaultcore.azure.net"
  subresource_names              = ["vault"]
}

module "user_managed_identity" {
  source        = "../../modules/private-endpoint"
  resource_group_name = module.rg.name
  name  = "${local.resourcePrefix}-umi-rcl-${var.resourceInstance}" 
  location      = var.location
}

# Adding federated idenntity credential for RCL monitoring managed identity as well

 resource "azurerm_federated_identity_credential" "aksRclMonitor" {   //federated creds for aks default agentpool

  for_each            = toset(local.fedCredAccount)
  name                = each.value
  resource_group_name = local.resourceGroup
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.zone == "connected" ? module.aksConnected[0].aksOIDCIssuerUrl : module.aksIsolated[0].aksOIDCIssuerUrl
  parent_id           = module.umi.resourceId
  subject             = "system:serviceaccount:${each.value}:${each.value}-sa" 
  lifecycle {
    ignore_changes = [
      issuer
    ]
  }

  depends_on = [ module.aksConnected,module.aksIsolated, module.umi ]
} 