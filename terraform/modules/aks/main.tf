resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.example.id

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    outbound_type       = "loadBalancer"
  }

  # Azure Monitor Container Insights.
  # This expects the Azure resource ID of the Log Analytics workspace.
  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_resource_id
    msi_auth_for_monitoring_enabled = true
  }

  # Enables Azure Monitor managed Prometheus metric collection on AKS.
  # A production implementation would also configure the Azure Monitor
  # workspace/data collection and Grafana integration as required.
  monitor_metrics {}
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
