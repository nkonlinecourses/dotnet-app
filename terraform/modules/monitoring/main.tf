resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "ag-${var.aks_cluster_name}"
  resource_group_name = var.resource_group_name
  short_name          = "aks-alerts"
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "pod_not_ready" {
  name                = "${var.aks_cluster_name}-pod-not-ready"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [azurerm_log_analytics_workspace.this.id]
  severity             = var.alert_severity
  description          = "Alerts when AKS reports pods outside Running/Succeeded states."
  enabled              = true

  criteria {
    query = <<-QUERY
      KubePodInventory
      | where ClusterName == "${var.aks_cluster_name}"
      | where PodStatus !in ("Running", "Succeeded")
    QUERY

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform.id]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "container_restarts" {
  name                = "${var.aks_cluster_name}-container-restarts"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.this.id]
  severity             = var.alert_severity
  description          = "Alerts when a container restart is observed in the AKS cluster."
  enabled              = true

  criteria {
    query = <<-QUERY
      KubePodInventory
      | where ClusterName == "${var.aks_cluster_name}"
      | where ContainerRestartCount > 0
    QUERY

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform.id]
  }
}
