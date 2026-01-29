# 🛠 Spec-Forge Infrastructure

[![Provider](https://img.shields.io/badge/DigitalOcean-AMS3-0080FF?style=flat-square&logo=digitalocean&logoColor=white)](https://www.digitalocean.com)
[![Terraform Cloud](https://img.shields.io/badge/State-Terraform_Cloud-5C4EE5?style=flat-square&logo=terraform&logoColor=white)](https://cloud.hashicorp.com/products/terraform)

[![Terraform](https://img.shields.io/badge/Terraform-v1.14+-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Nginx](https://img.shields.io/badge/Nginx-Reverse_Proxy-009639?style=flat-square&logo=nginx&logoColor=white)](https://nginx.org)

Infrastructure-as-Code for **Spec-Forge**. This repository manages the production environment on DigitalOcean using
Terraform and GitHub Actions.

---

## 🚀 Quick Start

### 📋 Prerequisites

Ensure you have the following environment configurations before starting:

* **Terraform CLI** installed
* **Required secrets** (see below)

### 💻 Run Locally

Run from the infra/ directory:

```bash
terraform login
terraform init
terraform plan \
  -var="digital_ocean_token=$DIGITAL_OCEAN_TOKEN" \
  -var="server_ssh_public_key=$SERVER_SSH_PUBLIC_KEY" \
  -var="gh_secret_sync_token=$GH_SECRET_SYNC_TOKEN" \
  -var="tf_cloud_organization=$TF_CLOUD_ORGANIZATION" \
  -var="tf_cloud_workspace=$TF_CLOUD_WORKSPACE" \
  -var="gh_target_repositories=$GH_TARGET_REPOSITORIES"
```

---

## 🔄 CI/CD Pipeline

| Event            | Action            | Description                                                         |
|:-----------------|:------------------|:--------------------------------------------------------------------|
| **Pull Request** | `terraform plan`  | Validates changes and posts the plan to the PR                      |
| **Tag (`v*`)**   | `terraform apply` | Provisions infrastructure, configures the server, and syncs secrets |

---

## 🔑 Required Secrets

* `DIGITAL_OCEAN_TOKEN`: For resource provisioning
* `HCP_TERRAFORM_TOKEN`: For remote state management
* `SERVER_SSH_PUBLIC_KEY`: SSH key injected into the root user
* `GH_SECRET_SYNC_TOKEN`: For syncing IP addresses to app repositories
* `TF_CLOUD_ORGANIZATION`: Terraform Cloud organization name
* `TF_CLOUD_WORKSPACE`: Terraform Cloud workspace name
* `GH_TARGET_REPOSITORIES`: List of GitHub repositories that receive the SERVER_IP secret

---

## 🏛️ System Overview

* **State Management:** HashiCorp Cloud Platform Terraform
* **Provider:** DigitalOcean (ams3)
* **OS:** Ubuntu 24.04
* **Network:** Static Reserved IP with Cloud Firewall (Ports 22, 80, 443 allowed)
* **Routing:** Nginx Reverse Proxy with automated Let's Encrypt SSL.

```mermaid
graph TD
    subgraph GitHub_Actions ["GitHub Actions (CI/CD)"]
        TF[Terraform Apply]
        Sync[Sync Secrets]
    end

    subgraph DigitalOcean ["DigitalOcean (Production)"]
        Firewall[Cloud Firewall]
        IP[Reserved Static IP]

        subgraph Droplet ["Ubuntu Droplet"]
            Nginx[Nginx Proxy]
            Acme[Acme Companion]
            App[App Containers]
        end

        Volume[(Persistent Volume<br/>SSL Certs)]
    end

    TF -->|Provisions| Droplet
    TF -->|Attaches| Volume
    Sync -->|Updates| AppRepo[App Repositories]
    Internet -->|HTTPS :443| Firewall
    Firewall --> IP
    IP --> Nginx
    Nginx -->|Routes| App
    Acme -->|Saves Certs| Volume
    Nginx -->|Reads Certs| Volume
```

## Zero-Config Routing

Any container joined to the `shared_network` with a `VIRTUAL_HOST` environment variable is automatically detected,
routed, and secured with HTTPS. No manual Nginx configuration is required.

---

## 🔧 Operations

**SSH Access**

```bash
ssh root@v-oleksiienko.xyz
```

## 📤 Outputs

Upon successful completion, Terraform exports:

- **`reserved_ip`** - The static IP address of the server
- **`domain_name`** - The primary DNS entry

---

## ⚖️ License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.
