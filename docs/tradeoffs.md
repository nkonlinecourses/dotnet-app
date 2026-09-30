# Assumptions, limitations and trade-offs

This repository is intentionally scoped as a reference implementation rather than a claim of full production readiness.

- Data is held in memory. A real system would use an appropriate persistent data store and migrations.
- The two services demonstrate independent deployment and internal HTTP communication without adding unnecessary messaging or service-mesh complexity.
- AKS is used because the project demonstrates container platform design and reusable Kubernetes patterns; for two tiny APIs alone, Azure Container Apps or App Service could be operationally simpler.
- Terraform modules demonstrate reuse; a production implementation would add remote state/bootstrap, policy enforcement, private endpoints, DNS and stronger environment separation.
- The Helm chart is shared to demonstrate a platform golden path. Production charts would add NetworkPolicy, PDB, workload identity, secret-provider integration and more detailed securityContext controls.
- The pipeline demonstrates shared stages/templates. Organisation-specific scanners, approval rules and service connections are represented as integration points because they depend on the target Azure DevOps organisation.


## Private connectivity

The Terraform example creates a dedicated private-endpoint subnet and private endpoints for Azure Container Registry and Azure Key Vault. Private DNS zones (`privatelink.azurecr.io` and `privatelink.vaultcore.azure.net`) are linked to the application VNet, and public network access is disabled on ACR and Key Vault. ACR uses the Premium SKU because Azure Private Link requires it.

AKS API-server private access is intentionally not enabled in this reference implementation. A private AKS cluster would require the deployment agent to have network reachability into the VNet (for example, a self-hosted Azure DevOps agent). This is documented as a production hardening option rather than hiding that operational dependency.
