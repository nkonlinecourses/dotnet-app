# Observability and operations

## What is implemented

The repository provisions a Log Analytics workspace and enables the AKS `oms_agent` integration so Container Insights can collect Kubernetes inventory, container/platform telemetry and application stdout/stderr. Both .NET services expose `/health`, and the Helm deployment uses readiness and liveness probes.

Azure Monitor managed Prometheus collection is enabled on AKS through the `monitor_metrics` block. For a fuller production implementation I would explicitly connect the managed Prometheus pipeline to a dedicated Azure Monitor Workspace and Azure Managed Grafana instance, with curated dashboards and recording rules.

Two demonstration Azure Monitor scheduled-query alerts are provisioned from Terraform:

- pods reported outside `Running` or `Succeeded` states;
- container restarts observed in `KubePodInventory`.

The alerts target an Azure Monitor Action Group. The sample intentionally does not commit a real email, webhook or incident-management destination; receivers should be configured per environment through approved configuration/secrets.

## Dashboards and signals

A production dashboard would cover the four golden signals plus Kubernetes health: request rate, latency, HTTP 5xx/error rate, CPU/memory saturation, replica availability, pod/container restarts and deployment health. Azure Managed Grafana is a natural extension when managed Prometheus is used.

## Failed deployment

1. Stop further promotion and communicate impact/ownership.
2. Check Azure DevOps deployment history, Kubernetes rollout status/events, application logs and recent configuration/image changes.
3. Roll back the Helm release to the last known-good revision if the new release is the cause.
4. Validate health endpoints and a small smoke test after recovery.
5. Preserve logs/timeline and complete root-cause analysis.
6. Add a preventive control: test, alert, validation, runbook or pipeline gate.

## Rollout strategy

The deployment uses Kubernetes rolling updates with readiness/liveness probes. For higher-risk production changes I would consider canary or blue/green deployment, automated health gates and progressive traffic shifting.

## Design trade-off

The implementation deliberately stops short of a complete enterprise observability platform. Application Insights/OpenTelemetry tracing, SLOs, alert routing to an on-call platform, Azure Managed Grafana dashboards and longer environment-specific retention are documented follow-on improvements rather than being hidden behind placeholder production claims.
