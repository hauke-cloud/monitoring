<!-- llm-readme-management spec=1 commit=a4d53378ed93cdddeadef49a4d07fbc12c2c71c8 template=helm model=qwen3.6-35b-a3b digest=5b6cfbe96d9f generated=2026-09-09T07:32:41Z -->
<a href="https://hauke.cloud" target="_blank"><img src="https://img.shields.io/badge/home-hauke.cloud-brightgreen" alt="hauke.cloud" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud" target="_blank"><img src="https://img.shields.io/badge/github-hauke.cloud-blue" alt="hauke.cloud Github Organisation" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud/llm-readme-management" target="_blank"><img src="https://img.shields.io/badge/template-helm-orange" alt="Repository type - helm" style="display: block;" /></a>


# Monitoring


<img src="https://raw.githubusercontent.com/hauke-cloud/.github/main/resources/img/organisation-logo-small.png" alt="hauke.cloud logo" width="109" height="123" align="right">


<llm header hint="Name the chart and what it deploys.">

The `monitoring` Helm chart deploys a Prometheus-based observability stack on Kubernetes, combining kube-prometheus-stack components with OAuth2 proxy protection and a Karma Alertmanager frontend. It is designed for you, a Kubernetes operator, who needs to install a complete monitoring suite behind single sign-on.

</llm>


## :book: Description

<llm description>

This repository provides a Helm chart that deploys a complete Prometheus-based monitoring stack on Kubernetes, designed for internal hauke.cloud teams who need observability behind single sign-on. You install the chart to provision Prometheus, Alertmanager, Grafana, and node-level metrics collection in a single release. The chart bundles kube-prometheus-stack with pre-configured resource limits and a 10-day data retention window, while routing all web interfaces through dedicated OAuth2 proxy instances backed by Redis Sentinel for secure session management.

Within the hauke-cloud setup, this chart serves as the central observability layer and publishes to ghcr.io/hauke-cloud/charts for consistent cluster-wide deployment. It configures Grafana to read admin credentials from an existing secret and enables a sidecar to automatically sync datasources and dashboards.

- Installs kube-prometheus-stack with Prometheus Operator, Alertmanager, Grafana, Node Exporter, and kube-state-metrics
- Deploys three aliased oauth2-proxy instances for SSO-protected access to each monitoring component
- Adds karma as a read-only Alertmanager UI behind its own proxy
- Pre-configures Grafana with an external admin secret and dashboard/datasource sidecar injection

</llm>


## :clipboard: Requirements

<llm requirements hint="Give the Kubernetes version constraint from Chart.yaml, the Helm version, and any dependency charts or CRDs that must already be present.">

- A Kubernetes cluster with RBAC enabled
- Helm 3.x with OCI support for consuming and publishing charts
- A pre-created Kubernetes Secret named `grafana-admin-secret` holding Grafana admin credentials
- An OIDC provider configured with client IDs, secrets, and cookie secrets for the three oauth2-proxy instances (if SSO is enabled)
- For local development: pre-commit 2.x (with `pre-commit-hooks` v4.6.0, `gitleaks` v8.18.4, `helm-docs` v1.14.2, and `gruntwork/pre-commit` v0.1.23)
- For CI releases: a GitHub Container Registry authentication token with package write permissions
- svu 3.2.3+ for semantic version bumping during the release pipeline

</llm>


## 🚀 Getting started

<llm getting_started hint="helm repo add, helm install and helm upgrade with the real repository URL and chart name. Show a values override only if the chart needs one to start.">

1. You clone the repository and enter the project directory.
```bash
git clone https://github.com/hauke-cloud/monitoring.git
cd monitoring
```
2. You resolve all sub-chart dependencies from their upstream repositories.
```bash
helm dependency build charts/monitoring
```
3. You render the complete manifest to verify your configuration before deployment.
```bash
helm template oci://ghcr.io/hauke-cloud/charts/monitoring
```
4. You deploy the monitoring stack to a Kubernetes cluster using Helm 3.
```bash
helm install monitoring oci://ghcr.io/hauke-cloud/charts/monitoring --version <tag>
```

</llm>


## :airplane: Usage

<llm usage hint="Show installing with a values file, and how to reach or verify the deployed workload.">

You consume this chart directly from the OCI registry rather than cloning the repository. To deploy the stack, provide a values file that satisfies the mandatory Grafana admin secret and any custom retention or replica settings.

```yaml
# custom-values.yaml
kube-prometheus-stack:
  grafana:
    admin:
      existingSecret: grafana-admin-secret
  prometheus:
    prometheusSpec:
      retention: 10d
      replicas: 1
```

Install the release by passing your values file and pinning a specific chart version. The `grafana-admin-secret` must already exist in your cluster, or the installation will fail.

```bash
helm install monitoring oci://ghcr.io/hauke-cloud/charts/monitoring \
  --version 0.1.0 \
  -f custom-values.yaml
```

After deployment, verify that all components are running and check their resource allocation. The chart delegates all workload manifests to its sub-charts, so you can inspect the release status or list the managed pods directly.

```bash
helm status monitoring
kubectl get pods -l app.kubernetes.io/instance=monitoring
```

To update the stack later, run `helm upgrade monitoring oci://ghcr.io/hauke-cloud/charts/monitoring --version 0.1.0 -f custom-values.yaml`. The three OAuth2 proxy instances and Karma frontend are automatically wired to their respective backends once the release is active.

</llm>


## :wrench: Configuration

<llm configuration hint="A table of the top-level values from values.yaml: key, default, description. Point at values.yaml for the full set.">

You configure this chart by passing overrides via `-f` or `--set` during installation. The table below lists the most frequently adjusted top-level values:

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `kube-prometheus-stack.prometheus.prometheusSpec.retention` | string | `"10d"` | No | Prometheus data retention period. |
| `kube-prometheus-stack.prometheus.prometheusSpec.replicas` | int | `1` | No | Number of Prometheus server replicas. |
| `kube-prometheus-stack.grafana.admin.existingSecret` | string | `"grafana-admin-secret"` | Yes | Pre-existing Kubernetes secret containing Grafana admin credentials. |
| `kube-prometheus-stack.*.enabled` | bool | `true` | No | Feature toggles for Prometheus, Grafana, Alertmanager, Node Exporter, and kube-state-metrics. |
| `oauth2-proxy-*\.enabled` | bool | inherited from oauth2-proxy chart default | No | Enables the three OAuth2 proxy instances protecting Prometheus, Alertmanager, and Karma. |

The configuration surface extends deeply into each sub-chart. You can override any nested key to adjust resource limits, OIDC client settings, or Redis Sentinel configurations. The complete set of defaults is documented in `values.yaml`.

</llm>


## 📄 License

This Project is licensed under the GNU General Public License v3.0

- see the [LICENSE](LICENSE) file for details.


## :coffee: Contributing

To become a contributor, please check out the [CONTRIBUTING](CONTRIBUTING.md) file.


## :email: Contact

For any inquiries or support requests, please open an issue in this
repository or contact us at [contact@hauke.cloud](mailto:contact@hauke.cloud).
