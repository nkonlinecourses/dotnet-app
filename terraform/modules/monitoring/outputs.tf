output "workspace_resource_id" {
  description = "Azure resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_customer_id" {
  description = "Log Analytics workspace customer/workspace GUID."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "action_group_id" {
  description = "Resource ID of the Azure Monitor action group."
  value       = azurerm_monitor_action_group.platform.id
}
