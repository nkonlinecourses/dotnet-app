# Architecture overview

The project uses two intentionally small .NET APIs so the focus remains on delivery and platform engineering rather than business complexity.

- **ProductService** exposes product lookup endpoints.
- **OrderService** exposes order endpoints and calls ProductService over HTTP.
- Both services are independently containerised and deployed to AKS using one reusable Helm chart.
- ACR stores versioned container images.
- Azure DevOps uses a shared parameterised pipeline for both services.
- Terraform modules define resource group, network, ACR, AKS, Key Vault and monitoring building blocks.

## Request path

`Client -> Ingress -> OrderService -> Kubernetes ClusterIP/DNS -> ProductService`

Only the required application routes should be exposed through ingress. Service-to-service traffic remains internal to the cluster.

## Namespace design

By default, use `microservices-dev` and `microservices-prod`. In a larger platform, namespace boundaries would be aligned to environment/application ownership and enforced with RBAC, quotas and NetworkPolicy.

## Image promotion

Build an immutable image once, tag it with the commit/build identifier, scan it, push it to ACR and promote the same image digest through environments. Do not rebuild source separately for production.


## Private connectivity

The Terraform example creates a dedicated private-endpoint subnet and private endpoints for Azure Container Registry and Azure Key Vault. Private DNS zones (`privatelink.azurecr.io` and `privatelink.vaultcore.azure.net`) are linked to the application VNet, and public network access is disabled on ACR and Key Vault. ACR uses the Premium SKU because Azure Private Link requires it.

AKS API-server private access is intentionally not enabled in this reference implementation. A private AKS cluster would require the deployment agent to have network reachability into the VNet (for example, a self-hosted Azure DevOps agent). This is documented as a production hardening option rather than hiding that operational dependency.
