

<a href="https://hauke.cloud" target="_blank"><img src="https://img.shields.io/badge/home-hauke.cloud-brightgreen" alt="hauke.cloud" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud" target="_blank"><img src="https://img.shields.io/badge/github-hauke.cloud-blue" alt="hauke.cloud Github Organisation" style="display: block;" /></a>
<a href="https://github.com/hauke-cloud/readme-management" target="_blank"><img src="https://img.shields.io/badge/template-helm-orange" alt="Repository type - helm" style="display: block;" /></a>


# monitoring


<img src="https://raw.githubusercontent.com/hauke-cloud/.github/main/resources/img/organisation-logo-small.png" alt="hauke.cloud logo" width="109" height="123" align="right">


Helm chart to deploy a prometheus based monitoring stack

This chart offers you:
- Prometheus
- Alertmanager
- SSO security
- SSH connect monitoring
- Grafana
- More alerts and rules





## 🚀 Getting started
To get started, you need to clone the repository. Follow the steps below:

### 1. Clone the repository

Use the following command to clone the repository:

```bash
git clone https://github.com/hauke-cloud/monitoring.git
```

### 2. Navigate to the repository directory

Once the repository is cloned, navigate to the directory:

```bash
cd monitoring
```

### 3. Check the content

```bash
ls -la
```

This will display all the files and directories in the cloned repository.



## :airplane: Usage
### Deploying the chart

Since we provide the chart in our public Github repository deploying it is
quite simple. You can run the following command to template and install the chart to your Kubernetes cluster:

#### Template the Helm chart

```bash
helm template oci://ghcr.io/hauke-cloud/charts/monitoring
```

#### Deploy the Helm chart

```bash
helm install monitoring oci://ghcr.io/hauke-cloud/charts/monitoring --version 1.0.0
```



## 📄 License

This Project is licensed under the GNU General Public License v3.0

- see the [LICENSE](LICENSE) file for details.


## :coffee: Contributing

To become a contributor, please check out the [CONTRIBUTING](CONTRIBUTING.md) file.


## :email: Contact

For any inquiries or support requests, please open an issue in this
repository or contact us at [contact@hauke.cloud](mailto:contact@hauke.cloud).

