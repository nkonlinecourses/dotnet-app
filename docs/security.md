# Security and governance

## Implemented / demonstrated

- No credentials or secrets are stored in source control.
- Azure DevOps service connections are expected to use workload identity federation where available.
- Terraform is modular and supports controlled infrastructure changes through pull requests.
- NuGet vulnerability and Terraform/IaC scanning are represented in the shared pipeline.
- Containers run as non-root through the Dockerfile runtime user.
- Kubernetes health probes and resource requests/limits are defined by the shared Helm chart.
- Key Vault is represented as a reusable Terraform module with RBAC and purge protection.

## Regulated-production hardening

With more time I would enable private AKS/API and ACR/Key Vault connectivity, Kubernetes NetworkPolicy, Azure Policy for AKS, Defender for Cloud/containers, signed images/SBOM, pinned scanner images, Key Vault CSI/workload identity, restricted egress, Pod Security admission, central audit retention and separation of deployment identities by environment.

## Access and release governance

Use least-privilege Azure RBAC, protected Azure DevOps environments, required reviewers for production, branch policies, immutable build artifacts and auditable service connections. Production deployment should consume an approved artifact rather than rebuilding it.

## Terraform pipeline identity and state

The infrastructure pipeline uses an Azure Resource Manager service connection designed for workload identity federation (OIDC), avoiding a long-lived `ARM_CLIENT_SECRET`. Terraform state is stored remotely in Azure Storage and authenticated with Microsoft Entra ID/RBAC. State storage should have public access disabled where the build-agent network design permits, soft delete/versioning enabled, and access restricted to the infrastructure pipeline identity and platform administrators.

Infrastructure apply is deliberately separated from plan. The saved plan is published as a pipeline artifact and the apply deployment targets an Azure DevOps Environment so approvals/checks are centrally governed and auditable rather than encoded as a self-approved YAML step. Production should use a separate least-privilege service connection/identity from non-production.


## Private connectivity

The Terraform example creates a dedicated private-endpoint subnet and private endpoints for Azure Container Registry and Azure Key Vault. Private DNS zones (`privatelink.azurecr.io` and `privatelink.vaultcore.azure.net`) are linked to the application VNet, and public network access is disabled on ACR and Key Vault. ACR uses the Premium SKU because Azure Private Link requires it.

AKS API-server private access is intentionally not enabled in this reference implementation. A private AKS cluster would require the deployment agent to have network reachability into the VNet (for example, a self-hosted Azure DevOps agent). This is documented as a production hardening option rather than hiding that operational dependency.
