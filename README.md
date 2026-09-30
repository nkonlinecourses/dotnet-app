# .NET Microservices Platform Demo

A small two-service .NET application demonstrating a reusable approach to **build, secure, deploy and operate containerised applications on Azure**. The repository combines application code with reusable CI/CD templates, Terraform modules, Helm deployment patterns, private connectivity, security controls and observability.

## Architecture

```text
Internet / Client
       |
       v
 AKS Ingress
   |       |
   |       +------------------+
   v                          v
OrderService ----------> ProductService
   |       internal HTTP / Kubernetes DNS
   +--------------------------+

Azure DevOps -> Build/Test/Scan -> ACR -> AKS
Terraform    -> RG/VNet/ACR/AKS/Key Vault/Monitoring
Azure Monitor / Log Analytics <- platform and application telemetry
```

See `docs/architecture.md` for design details.

## Repository map

- `src/` - ProductService and OrderService .NET APIs
- `tests/` - xUnit tests
- `deploy/helm/` - reusable Helm chart used by both services
- `terraform/modules/` - reusable Azure infrastructure modules
- `terraform/environments/` - environment composition and values
- `pipelines/templates/` - shared Azure DevOps pipeline library
- `pipelines/product-service.yml` and `order-service.yml` - thin service pipelines

## Run locally

Prerequisites: .NET 8 SDK and optionally Docker Desktop.

```bash
dotnet restore
dotnet build
dotnet test
```

Run ProductService on port 5001 and OrderService on port 5002 using the included launch profiles, or run both containers:

```bash
docker compose up --build
```

Test:

```bash
curl http://localhost:5001/api/products
curl -X POST http://localhost:5002/api/orders -H "Content-Type: application/json" -d '{"productId":1,"quantity":2}'
```

## CI/CD approach

Both services consume the same parameterised `pipelines/templates/service-ci-cd.yml` golden path. The intended flow is:

`Restore -> Build -> Test -> Publish artifact -> dependency/IaC scan -> Docker build -> image scan -> ACR -> DEV -> smoke test -> protected environment approval -> PROD`

The production implementation should **build once and promote the same immutable image digest**, rather than rebuild per environment. Azure DevOps Environment checks/approvals provide the human production gate and audit trail.

## Infrastructure as Code

Terraform is split into reusable modules for resource group, network, ACR, AKS, Key Vault and Log Analytics. Environment folders compose these modules and provide environment-specific values. In a real implementation, Terraform state would be held in an Azure Storage backend with RBAC and locking, bootstrapped separately from the workload stack.

## AKS approach

- Environment-specific namespace (`microservices-dev`, `microservices-prod`)
- ClusterIP for internal service-to-service communication
- Ingress only for required external routes
- Rolling updates with readiness/liveness probes
- Resource requests/limits and HPA
- Secrets supplied from Key Vault through workload identity/CSI in the hardened design
- Production additions: NetworkPolicy, PDB, Pod Security, private endpoints and restricted egress

## Security

No secrets belong in Git or YAML. Prefer workload identity federation for Azure DevOps/Azure authentication and AKS workload identity for applications. Use least privilege, protected production environments, branch policies and auditable approvals.

## Observability and operations

Use application stdout/stderr plus Azure Monitor/Log Analytics for centralized telemetry. Alert on availability, 5xx/latency, pod restarts and resource saturation. A failed release is halted, diagnosed using pipeline/Kubernetes/application evidence, rolled back to the last known-good Helm revision, validated, and followed by RCA/preventive action.

## Terraform Azure DevOps pipeline

Infrastructure changes use the separate `pipelines/terraform.yml` pipeline rather than being coupled to an application release. The pipeline is parameterised for `dev`, `test` and `prod` and reuses `terraform-plan.yml` and `terraform-apply.yml`.

Default behaviour is **plan only**. Set the `apply` parameter to `true` for an intentional infrastructure deployment. The apply stage targets the Azure DevOps Environment `infrastructure-<environment>`; configure Approval and Checks on TEST/PROD (and DEV if desired) so approval is enforced outside YAML and remains auditable.

Flow:

```text
Terraform change / PR
        |
        v
terraform fmt -check
        |
terraform init (Azure Storage remote state)
        |
terraform validate
        |
Trivy IaC scan
        |
terraform plan
        |
publish saved .tfplan artifact
        |
Azure DevOps Environment approval
        |
terraform apply <saved-plan>
```

The Azure Resource Manager service connection is expected to use **workload identity federation**. No client secret is stored in Git. Backend values are pipeline configuration and the state storage account/container are bootstrapped separately. The service connection requires only the RBAC needed for the selected environment and access to the Terraform state container.

Before running, replace the example values in `pipelines/terraform.yml` (`sc-azure-platform-wif`, state resource group/storage account/container) and copy the appropriate `terraform.tfvars.example` to a securely managed `terraform.tfvars` or supply variables through the pipeline/approved variable groups.


## Private connectivity

The Terraform example creates a dedicated private-endpoint subnet and private endpoints for Azure Container Registry and Azure Key Vault. Private DNS zones (`privatelink.azurecr.io` and `privatelink.vaultcore.azure.net`) are linked to the application VNet, and public network access is disabled on ACR and Key Vault. ACR uses the Premium SKU because Azure Private Link requires it.

AKS API-server private access is not enabled in the base configuration. Enabling a private AKS cluster requires the deployment agent to have network reachability into the VNet, for example through a self-hosted Azure DevOps agent. This can be enabled as an additional network-hardening option where required.

See `docs/private-connectivity.md` for the Private Endpoint topology and the Azure DevOps self-hosted-agent implication.

## Observability implementation

The Terraform monitoring module creates Log Analytics and Azure Monitor alerting resources. AKS sends Container Insights telemetry to that workspace through the `oms_agent` integration, and managed Prometheus collection is enabled with `monitor_metrics`. The sample provisions two Kubernetes-focused scheduled-query alerts and an Action Group. See `docs/operations.md` for implemented controls, operational response, dashboards and production follow-on improvements.

## Pipeline template library

The Azure DevOps pipelines use a layered reusable library: thin consumer pipelines call stage templates in `pipelines/templates/`, which compose `pipelines/jobs/` and reusable `pipelines/steps/`. See `pipelines/README.md` for the template contracts and required pipeline configuration.
