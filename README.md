<!-- llm-readme-management spec=1 commit=3948594cd5d12ac8ee4dde3d78ec96d2fb5741f3 template=helm model=qwen3.8-27b-q4 digest=5b6cfbe96d9f generated=2026-10-12T08:58:03Z -->
<a href="https://hauke.cloud" target="_blank"><img src="https://img.shields.io/badge/home-hauke.cloud-brightgreen" alt="hauke.cloud" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud" target="_blank"><img src="https://img.shields.io/badge/github-hauke.cloud-blue" alt="hauke.cloud Github Organisation" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud/llm-readme-management" target="_blank"><img src="https://img.shields.io/badge/template-helm-orange" alt="Repository type - helm" style="display: block;" /></a>


# Monitoring


<img src="https://raw.githubusercontent.com/hauke-cloud/.github/main/resources/img/organisation-logo-small.png" alt="hauke.cloud logo" width="109" height="123" align="right">


<llm header hint="Name the chart and what it deploys.">

This Helm chart, published as `monitoring` on `oci://ghcr.io/hauke-cloud/charts`, deploys a Prometheus-based monitoring stack—Prometheus, Alertmanager, Grafana, and the Karma alert UI—into a Kubernetes cluster. It wraps the `kube-prometheus-stack` and `karma` subcharts with pre-set defaults for retention, replicas, and resource limits. If you operate a Kubernetes cluster and want a ready-to-install monitoring bundle, keep reading.

</llm>


## :book: Description

<llm description>

This repository contains a single Helm chart that deploys a Prometheus-based monitoring stack into a Kubernetes cluster. It wraps two upstream charts — `kube-prometheus-stack` 91.2.3 and `karma` 2.13.1 — and ships pre-configured defaults so you can install a working Prometheus, Alertmanager, Grafana, and Karma alert-viewing UI with one `helm install` command.

The chart itself renders no resources; all behaviour lives in the two pinned subcharts. You configure the stack by overriding the `kube-prometheus-stack` and `karma` value subtrees in your own values file. The published chart is available at `oci://ghcr.io/hauke-cloud/charts/monitoring` and is versioned and pushed automatically on every push to `main`.

- Prometheus with 10-day retention and a single replica by default
- Grafana with sidecar-managed datasources and dashboards (label `grafana_dashboard`)
- Alertmanager with a single replica
- node-exporter and kube-state-metrics for node and cluster metrics
- Prometheus Operator with CRDs and admission webhooks
- Karma (Alertmanager alert-viewing UI) with upstream defaults

It is one of the Helm charts published by the `hauke-cloud` organisation to the `ghcr.io/hauke-cloud/charts` OCI registry.

</llm>


## :clipboard: Requirements

<llm requirements hint="Give the Kubernetes version constraint from Chart.yaml, the Helm version, and any dependency charts or CRDs that must already be present.">

- **Helm 3** with OCI registry support. No specific version is pinned; CI installs the latest via `azure/setup-helm@v4`.
- **A Kubernetes cluster** with sufficient capacity for the chart's hardcoded resource requests (e.g. Prometheus: 1 CPU / 1 Gi) and RBAC permissions for the Prometheus Operator admission webhooks. No `kubeVersion` constraint is declared in `Chart.yaml`.
- **A pre-existing Secret** named `grafana-admin-secret` in the target namespace (or an override of `kube-prometheus-stack.grafana.admin.existingSecret`) holding the Grafana admin credentials. The chart does not create this secret.
- **Dependency charts** `kube-prometheus-stack` 91.2.3 and `karma` 2.13.1, resolved automatically from the published OCI package or via `helm dependency build` when working from source.
- **Prometheus Operator CRDs** are installed by the chart itself (`createCustomResource: true`); no separate pre-installation is needed.
- **For contributing:** `pre-commit` and Helm (for the `helm-docs` and `helm lint` hooks defined in `.pre-commit-config.yaml`).

</llm>


## 🚀 Getting started

<llm getting_started hint="helm repo add, helm install and helm upgrade with the real repository URL and chart name. Show a values override only if the chart needs one to start.">

1. Clone the repository.

```bash
git clone https://github.com/hauke-cloud/monitoring.git
cd monitoring
```

2. Create the Grafana admin secret in the target namespace. The chart reads credentials from a pre-existing secret named `grafana-admin-secret` and does not create it; the command below is the conventional `kubectl` way to supply it.

```bash
kubectl create secret generic grafana-admin-secret \
  --from-literal=admin-user=admin \
  --from-literal=admin-password=changeme
```

3. Install the published chart into your cluster. Helm 3 with OCI support is required; no registry login is needed for public pulls.

```bash
helm install monitoring oci://ghcr.io/hauke-cloud/charts/monitoring
```

After the release reaches `deployed` status, Prometheus, Alertmanager, Grafana, node-exporter, kube-state-metrics, and the Karma alert UI are running in the target namespace. You can verify with `kubectl get pods -n <namespace>` and reach Grafana through a port-forward or ingress you configure separately.

</llm>


## :airplane: Usage

<llm usage hint="Show installing with a values file, and how to reach or verify the deployed workload.">

Install the chart from the OCI registry, passing a values file to override the built-in defaults:

```bash
helm install monitoring oci://ghcr.io/hauke-cloud/charts/monitoring \
  --version 1.0.0 \
  -f values.yaml
```

A typical `values.yaml` adjusts Prometheus retention or points Grafana at a different pre-existing secret:

```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      retention: 10d
  grafana:
    admin:
      existingSecret: grafana-admin-secret
```

The secret named by `kube-prometheus-stack.grafana.admin.existingSecret` (default `grafana-admin-secret`) must already exist in the install namespace; the chart does not create it.

Once the release is deployed, confirm that the expected workloads are running:

```bash
kubectl get pods
```

You should see pods for Prometheus, Grafana, Alertmanager, node-exporter, kube-state-metrics, the Prometheus Operator, and Karma. To render the chart locally without installing, use:

```bash
helm template oci://ghcr.io/hauke-cloud/charts/monitoring
```

</llm>


## :wrench: Configuration

<llm configuration hint="A table of the top-level values from values.yaml: key, default, description. Point at values.yaml for the full set.">

The chart defines no parent-level values of its own beyond the standard `nameOverride` / `fullnameOverride` naming helpers. All configuration is passed through to the two subcharts (`kube-prometheus-stack` 91.2.3 and `karma` 2.13.1) under their respective top-level keys. The `karma` subchart receives no overrides and deploys with its upstream defaults. The table below lists the entries that `charts/monitoring/values.yaml` sets explicitly; any other `kube-prometheus-stack` or `karma` value can be passed through with the same key structure. See `charts/monitoring/values.yaml` for the full set.

| Key | Default | Description |
|-----|---------|-------------|
| `kube-prometheus-stack.prometheus.enabled` | `true` | Enable the Prometheus server. |
| `kube-prometheus-stack.prometheus.prometheusSpec.retention` | `10d` | Prometheus data retention period. |
| `kube-prometheus-stack.prometheus.prometheusSpec.replicas` | `1` | Number of Prometheus replicas. |
| `kube-prometheus-stack.grafana.enabled` | `true` | Enable the Grafana dashboard. |
| `kube-prometheus-stack.grafana.admin.existingSecret` | `"grafana-admin-secret"` | Name of a pre-existing Secret holding Grafana admin credentials. The chart does not create this Secret; an unmodified install will not provide a working admin password unless you create it. |
| `kube-prometheus-stack.alertmanager.enabled` | `true` | Enable Alertmanager. |
| `kube-prometheus-stack.alertmanager.alertmanagerSpec.replicas` | `1` | Number of Alertmanager replicas. |
| `kube-prometheus-stack.nodeExporter.enabled` | `true` | Enable node-exporter. |
| `kube-prometheus-stack.kubeStateMetrics.enabled` | `true` | Enable kube-state-metrics. |
| `kube-prometheus-stack.prometheusOperator.createCustomResource` | `true` | Install Prometheus Operator CRDs and admission webhooks. |

CPU and memory requests/limits for every component are set as hardcoded defaults in the same file and are not exposed as separate top-level keys.

</llm>


## 📄 License

This Project is licensed under the GNU General Public License v3.0

- see the [LICENSE](LICENSE) file for details.


## :coffee: Contributing

To become a contributor, please check out the [CONTRIBUTING](CONTRIBUTING.md) file.


## :email: Contact

For any inquiries or support requests, please open an issue in this
repository or contact us at [contact@hauke.cloud](mailto:contact@hauke.cloud).
