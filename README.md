# CloudDevOpsProject
---
## Project Overview

This repository contains the implementation of a modern DevOps pipeline for deploying a sample application. The project integrates various tools and technologies to achieve containerization, orchestration, infrastructure provisioning, configuration management, continuous integration, and continuous deployment. Each section below links to its detailed documentation for further reference.

---

## Table of Contents

1. [Containerization with Docker](./FinalProjectCode)
2. [Container Orchestration with Kubernetes](./Kubernetes)
3. [Infrastructure Provisioning with Terraform](./Terraform)
4. [Configuration Management with Ansible](./Ansible)
5. [Continuous Integration with Jenkins](./jenkins)
6. [Continuous Deployment with ArgoCD](ArgoCD)

---

## Containerization with Docker

**Task:**
- Deliver a Dockerfile for building the application image.
- Source code is available at: [https://github.com/IbrahimAdell/FinalProjectCode.git](https://github.com/IbrahimAdell/FinalProjectCode.git).

**Detailed Documentation:**  
[Read more about Docker setup here](./FinalProjectCode/README.md)

---

## Container Orchestration with Kubernetes

**Task:**
- Set up a Kubernetes cluster.
- Create the `iVolve` namespace.
- Configure Deployment, Service, and Ingress to access the application.

**Detailed Documentation:**  
[Read more about Kubernetes setup here](./kubernetes/README.md)

---

## Infrastructure Provisioning with Terraform

**Task:**
- Deliver Terraform scripts for AWS resource provisioning:
  - VPC, Subnet, Security Groups.
  - 2 EC2 instances for application deployment.
  - Use S3 as the Terraform backend state.
  - Integrate CloudWatch for monitoring.
  - Utilize Terraform Modules.

**Detailed Documentation:**  
[Read more about Terraform setup here](./Terraform/README.md)

---

## Configuration Management with Ansible

**Task:**
- Deliver Ansible playbooks for EC2 instance configuration:
  - Install required packages (e.g., Git, Docker, Java).
  - Install packages for Jenkins.
  - Install packages for SonarQube.
  - Set up necessary environment variables.
  - Use Ansible roles and Dynamic Inventory.

**Detailed Documentation:**  
[Read more about Ansible setup here](./Ansible/README.md)

---

## Continuous Integration with Jenkins

**Task:**
- Deliver Jenkins pipeline configuration in a `Jenkinsfile`:
  - Stages: Unit Test, SonarQube Test, Build JAR, Build Image, Push Image, Delete Image Locally, Update Manifests, Push Manifests.
  - Use a Shared Library.
  - Utilize a Jenkins slave.

**Detailed Documentation:**  
[Read more about Jenkins setup here](./jenkins/README.md)

---

## Continuous Deployment with ArgoCD

**Task:**
- Configure ArgoCD to sync and deploy the application into the Kubernetes cluster.

**Detailed Documentation:**  
[Read more about ArgoCD setup here](./ArgoCD/README.md)

---

## Getting Started

To set up and run this project locally or in your environment, please refer to the detailed documentation linked above for each component. Ensure you have the necessary prerequisites (e.g., Docker, Kubernetes, Terraform, Ansible, Jenkins, ArgoCD) installed and configured.

1. Clone this repository:
   ```bash
   git clone https://github.com/HadeerAlaa542/FinalProjectCode.git
   ```
2. Follow the instructions in each section's README for setup and deployment.

---

