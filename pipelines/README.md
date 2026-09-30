# Pipeline library

The pipeline layout follows a layered template-library pattern:

```text
consumer pipeline -> templates (stages) -> jobs -> steps
```

- `product-service.yml` / `order-service.yml`: thin consumer pipelines containing service-specific configuration.
- `terraform.yml`: thin infrastructure consumer pipeline.
- `templates/`: stage-level orchestration and dependencies.
- `jobs/`: job/deployment boundaries and agent selection.
- `steps/`: small reusable implementation units.

This keeps application repositories focused on parameters while shared engineering logic can be versioned centrally. The `pipelines/` directory can later be extracted to a dedicated Azure DevOps repository and referenced with `resources.repositories` plus `@repositoryAlias`, without changing the template contracts.

## Required pipeline configuration

Define the following as pipeline/variable-group values appropriate to each environment:

- `azureServiceConnection`
- `acrServiceConnection`
- `acrLoginServer`
- `aksResourceGroup`
- `aksClusterName`
- `privateAgentPool` (needed where ACR/AKS are reachable only through private networking)
- `backendResourceGroup`
- `backendStorageAccount`
- `backendContainer`

Terraform environment configuration is supplied explicitly through `dev.tfvars`, `test.tfvars`, or `prod.tfvars`. These files must contain non-secret configuration only. Sensitive values should come from approved secret stores or protected pipeline variables.
