# Kubernetes GitOps Platform on AWS EKS

Infrastructure as Code (IaC) for provisioning a production-ready **AWS EKS** Kubernetes platform using **Terraform**. This repository is the foundation layer of a GitOps-based delivery model built on **ArgoCD**, **Helm**, **Prometheus**, **Grafana**, and **Alertmanager**.

---

## Table of Contents

- [Overview](#overview)
- [Project Objectives](#project-objectives)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Repository Structure](#repository-structure)
- [Related Repositories](#related-repositories)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Infrastructure Components](#infrastructure-components)
- [Environments](#environments)
- [Verification](#verification)
- [Cleanup](#cleanup)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Author](#author)

---

## Overview

This repository provisions the AWS infrastructure required to run Kubernetes workloads on Amazon EKS. It handles the **infrastructure layer only**. Node configuration and application deployment are handled by separate repositories (see [Related Repositories](#related-repositories)).

Once the cluster is up, applications are delivered declaratively through GitOps: Git is the single source of truth, and ArgoCD continuously reconciles the cluster to match it.

## Project Objectives

- Provision an AWS EKS cluster using Terraform
- Create managed worker nodes to run Kubernetes workloads
- Provide a foundation for GitOps-based application deployment
- Integrate with Ansible-based worker-node configuration
- Support monitoring and alerting out of the box
- Support separate staging and production environments

## Architecture

```text
                         GitHub
                           |
                    Terraform Code
                           |
                           v
                    +-------------+
                    |   AWS VPC   |
                    +-------------+
                           |
                           v
                    +-------------+
                    |   AWS EKS   |
                    |   Cluster   |
                    +-------------+
                           |
              +------------+------------+
              |            |            |
              v            v            v
        Worker Node   Worker Node   Worker Node
              |
              +-----------------------------+
              |                             |
              v                             v
       Kubernetes Apps                  Monitoring
       - Service 1                      - Prometheus
       - Service 2                      - Grafana
       - Service 3                      - Alertmanager
              |
              v
             HPA
```

**Flow summary:** Terraform provisions the VPC and EKS cluster, worker nodes join the cluster, and applications plus the monitoring stack run on top. The Horizontal Pod Autoscaler (HPA) scales workloads based on demand.

## Technology Stack

| Technology   | Purpose                          |
|--------------|----------------------------------|
| AWS          | Cloud platform                   |
| EKS          | Managed Kubernetes               |
| Terraform    | Infrastructure as Code           |
| Kubernetes   | Container orchestration          |
| Helm         | Application packaging            |
| ArgoCD       | GitOps continuous delivery       |
| Prometheus   | Metrics collection               |
| Grafana      | Metrics visualization            |
| Alertmanager | Alert management                 |
| Ansible      | Worker-node configuration        |

## Repository Structure

```text
k8s-gitops-platform/
│
├── terraform/
│   ├── main.tf            # Core resources (VPC, EKS, node groups)
│   ├── variables.tf       # Input variable definitions
│   ├── outputs.tf         # Output values (cluster name, endpoint, etc.)
│   ├── providers.tf       # Provider and backend configuration
│   ├── terraform.tfvars   # Variable values
│   └── modules/           # Reusable Terraform modules
│
├── environments/
│   ├── dev/               # Development / staging configuration
│   └── prod/              # Production configuration
│
├── scripts/               # Helper scripts
│
└── README.md
```

> **Note:** Update this tree to match the actual contents of your repository.

## Related Repositories

This repository is one part of a three-repository platform:

| Repository            | Responsibility                                  |
|-----------------------|-------------------------------------------------|
| `k8s-gitops-platform` | Provisions AWS infrastructure (this repository) |
| `k8s-ansible-config`  | Configures the worker nodes                     |
| `k8s-gitops-config`   | Application manifests deployed through ArgoCD   |

```text
k8s-gitops-platform
        |
        | Terraform
        v
     AWS EKS
        |
        v
k8s-ansible-config
        |
        | Node configuration
        v
   Worker Nodes
        |
        v
k8s-gitops-config
        |
        | ArgoCD
        v
Kubernetes Applications
```

## Prerequisites

Install the following tools:

| Tool      | Purpose                              |
|-----------|--------------------------------------|
| AWS CLI   | Authenticate and interact with AWS   |
| Terraform | Provision infrastructure             |
| kubectl   | Interact with the Kubernetes cluster |
| Helm      | Install Kubernetes packages          |
| Git       | Clone and manage the repository      |

Configure your AWS credentials:

```bash
aws configure
```

Verify AWS access:

```bash
aws sts get-caller-identity
```

> Your IAM user or role needs permissions to create VPC, EKS, IAM, and EC2 resources.

## Getting Started

### 1. Clone the repository

```bash
git clone <REPOSITORY_URL>
cd k8s-gitops-platform/terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Review the execution plan

```bash
terraform plan
```

### 5. Apply the infrastructure

```bash
terraform apply
```

### 6. Configure kubectl

After the EKS cluster is created, update your kubeconfig:

```bash
aws eks update-kubeconfig \
  --region <AWS_REGION> \
  --name <EKS_CLUSTER_NAME>
```

### 7. Verify the cluster

```bash
kubectl get nodes
```

Example output:

```text
NAME                                      STATUS   ROLES    AGE
ip-10-0-1-100.<region>.compute.internal   Ready    <none>   10m
ip-10-0-2-100.<region>.compute.internal   Ready    <none>   10m
ip-10-0-3-100.<region>.compute.internal   Ready    <none>   10m
```

## Infrastructure Components

Terraform provisions the following AWS resources:

| Component                 | Description                                         |
|---------------------------|-----------------------------------------------------|
| VPC                       | Isolated virtual network for the platform           |
| Public / private subnets  | Spread across availability zones                    |
| Internet / NAT gateways   | Outbound access for public and private subnets      |
| Route tables              | Traffic routing between subnets and gateways        |
| EKS cluster               | Managed Kubernetes control plane                    |
| EKS node groups           | Worker nodes that run workloads                     |
| IAM roles                 | Permissions for the cluster and nodes               |
| Security groups           | Network access control                              |

## Environments

The platform supports two separate Kubernetes environments:

| Environment | Purpose                             |
|-------------|-------------------------------------|
| Staging     | Testing and validation before release |
| Production  | Live workloads                      |

Environment-specific settings are managed through **Terraform variables** and **Kubernetes/GitOps configuration**. Keep each environment's state and variables separate to avoid accidental cross-environment changes.

## Verification

**Check the EKS cluster:**

```bash
aws eks describe-cluster \
  --name <EKS_CLUSTER_NAME> \
  --region <AWS_REGION>
```

**Check the nodes:**

```bash
kubectl get nodes
```

**Check the namespaces:**

```bash
kubectl get namespaces
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

> **Warning:** This permanently deletes the cluster and its resources. Make sure all workloads and dependent resources can safely be removed before running this command.

## Best Practices

- Use a **remote backend** (for example, S3 with DynamoDB locking) for Terraform state
- Never commit secrets or credentials; keep sensitive values out of `terraform.tfvars`
- Always run `terraform plan` and review it before `terraform apply`
- Use separate state and variables per environment
- Tag all resources consistently for cost tracking and ownership

## Troubleshooting

| Problem                          | What to check                                                        |
|----------------------------------|----------------------------------------------------------------------|
| `terraform init` fails           | Network access and backend configuration in `providers.tf`           |
| AWS authentication errors        | Run `aws sts get-caller-identity` and confirm the correct profile    |
| `kubectl` cannot connect         | Re-run `aws eks update-kubeconfig` with the correct region and name  |
| Nodes are `NotReady`             | Check node group IAM roles, security groups, and subnet routing      |
| `terraform destroy` hangs        | Delete Kubernetes-created resources (such as load balancers) first   |

## Author

**Pratik**
