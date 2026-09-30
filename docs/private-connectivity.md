# Private connectivity

## Implemented

- Dedicated `snet-private-endpoints` subnet.
- ACR Private Endpoint using subresource `registry`.
- Key Vault Private Endpoint using subresource `vault`.
- Private DNS zones linked to the VNet:
  - `privatelink.azurecr.io`
  - `privatelink.vaultcore.azure.net`
- Public network access disabled for ACR and Key Vault.
- ACR uses Premium SKU because Private Link support requires it.

## CI/CD implication

Once ACR public access is disabled, a Microsoft-hosted Azure DevOps agent cannot push images through the private endpoint. The container-build stage therefore references a self-hosted agent pool (`REPLACE-private-agent-pool`) with network and DNS reachability to the VNet.

The AKS API remains public in this reference implementation, protected through Azure access controls. A regulated production design could enable private AKS; the Helm deployment stage would then also need to run from a VNet-connected self-hosted agent.

## DNS flow

AKS nodes and VNet-connected build agents resolve the normal ACR/Key Vault service FQDNs through Azure Private DNS to private endpoint IP addresses. Applications should continue to use the standard service hostnames rather than hard-coded private IPs.
