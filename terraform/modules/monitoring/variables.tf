variable "name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the monitoring resources."
  type        = string
}

variable "aks_cluster_name" {
  description = "AKS cluster name used to scope Kubernetes alert queries."
  type        = string
}

variable "retention_in_days" {
  description = "Log Analytics retention period."
  type        = number
  default     = 30
}

variable "alert_severity" {
  description = "Azure Monitor severity for the demonstration alerts."
  type        = number
  default     = 2
}
