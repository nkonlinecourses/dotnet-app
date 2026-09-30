variable "location" {
  description = "Azure region for the environment."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "vnet_cidr" { type = string }
variable "aks_subnet_cidr" { type = string }
variable "private_endpoint_subnet_cidr" { type = string }
variable "key_vault_name" { type = string }
variable "acr_name" { type = string }
variable "aks_name" { type = string }

variable "node_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}
