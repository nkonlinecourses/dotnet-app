output "private_endpoint_id" {
  value = azurerm_private_endpoint.this.id
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.this.id
}
