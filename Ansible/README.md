# Ansible Configuration Management

This directory contains the Ansible setup for configuring two EC2 instances provisioned via Terraform in AWS. The playbooks and roles install required packages (Git, Docker, Java), set up Jenkins on the "master" instance, and configure SonarQube on the "slave" instance, using a dynamic inventory to target the instances.

## Overview

The Ansible configuration automates the setup of two EC2 instances:
- **Master**: Configured with Jenkins.
- **Slave**: Configured with SonarQube.
- **Common**: Both instances receive base packages (e.g., Git, Docker, Java).

The setup uses roles for modularity and a dynamic AWS EC2 inventory to identify instances by their `Name` tags (`master` and `slave`).

## Directory Structure

```
Ansible/
├── ansible.cfg              # Ansible configuration file
├── inventory_aws_ec2.yaml   # Dynamic inventory configuration for AWS EC2
├── roles                    # Ansible roles for modular configuration
│   ├── common               # Common tasks applied to all instances
│   │   └── tasks
│   │       └── main.yaml
│   ├── jenkins              # Role for Jenkins setup
│   │   ├── defaults
│   │   │   └── main.yaml   # Default variables for Jenkins
│   │   └── tasks
│   │       └── main.yaml
│   └── SonarQube            # Role for SonarQube setup
│       ├── tasks
│       │   └── main.yaml
│       └── vars
│           └── main.yaml   # Variables specific to SonarQube
└── site.yaml                # Main playbook to orchestrate roles
```

## Prerequisites

1. **Ansible**: Installed on the control node (version 2.9+ recommended).
2. **AWS CLI**: Configured with credentials to access EC2 instances.
3. **Terraform Setup**: Ensure Terraform has provisioned 2 EC2 instances with tags `Name: master` and `Name: slave`.
4. **SSH Key**: The `ivolve-key.pem` file available at `~/.ssh/ivolve-key.pem`.
5. **Python boto3**: Required for the AWS EC2 inventory plugin.

Install dependencies on the control node:
```bash
pip install boto3
ansible-galaxy collection install amazon.aws
```

## Configuration Details

### `ansible.cfg`
```ini
[defaults]
inventory = inventory_aws_ec2.yaml
private_key_file = ~/.ssh/ivolve-key.pem
host_key_checking = False
enable_plugins = aws_ec2
remote_user = ubuntu
```
- Specifies the inventory file, SSH key, and remote user (`ubuntu`).
- Disables host key checking for simplicity.

### `inventory_aws_ec2.yaml`
```yaml
plugin: aws_ec2
regions:
  - us-east-1  
filters:
  instance-state-name: running
  tag:Name: [master, slave] 
keyed_groups:
  - key: tags.Name
    separator: ""
    prefix: "tag_Name"
compose:
  ansible_host: public_ip_address
```
- Uses the `aws_ec2` plugin to dynamically fetch running EC2 instances in `us-east-1`.
- Filters instances with `Name` tags `master` or `slave`.
- Groups instances as `tag_Namemaster` and `tag_Nameslave`.
- Sets `ansible_host` to the public IP address of each instance.

### `site.yaml`
```yaml
- name: Configure all instances with common packages
  hosts: all
  roles:
    - common

- name: Configure master with Jenkins
  hosts: tag_Namemaster
  roles:
    - jenkins
    
- name: Configure slave with SonarQube
  hosts: tag_Nameslave
  become: yes
  roles:
    - SonarQube
```
- Applies the `common` role to all instances.
- Configures the `master` instance with Jenkins.
- Configures the `slave` instance with SonarQube, using `become: yes` for sudo privileges.

## Setup Instructions

1. **Verify AWS Credentials**:
   Ensure AWS CLI is configured with valid credentials:
   ```bash
   aws configure
   ```

2. **Test the Inventory**:
   Confirm Ansible can detect the EC2 instances:
   ```bash
   ansible-inventory -i inventory_aws_ec2.yaml --graph
   ```
<img width="508" alt="image" src="https://github.com/user-attachments/assets/5a2df257-2fea-498b-93b5-759058bc9db6" />
   
   Expected output includes groups `tag_Namemaster` and `tag_Nameslave`.

3. **Run the Playbook**:
   Execute the playbook to configure both instances:
   ```bash
   ansible-playbook -i inventory_aws_ec2.yaml site.yaml --private-key ~/.ssh/ivolve-key.pem 
   ```
![image](https://github.com/user-attachments/assets/9ca23bc4-d997-4c98-8719-04fb3c9a6b25)
   

## Verification
After running the playbook, SSH into each instance to verify:
- **Common Packages** (both instances):
  ```bash
  git --version
  java -version
  sudo systemctl status docker 
  ```
- **Master Instance** (Jenkins):
  ```bash
  sudo systemctl status jenkins
  ```
- **Slave Instance** (SonarQube):
  ```bash
  sudo systemctl status sonarqube
  ```
### Verification on the Master 

![image](https://github.com/user-attachments/assets/e082d406-9da5-4966-88dc-10f797b54895)

<img width="448" alt="image" src="https://github.com/user-attachments/assets/3f73f23e-6364-4917-b0da-ee5e04dc2ff8" />

![image](https://github.com/user-attachments/assets/142ca093-70d6-40b7-93a0-e1f8558d8832)


### Verification on the Slave

![image](https://github.com/user-attachments/assets/702d7379-a97c-41e5-884e-51674f980991)

![image](https://github.com/user-attachments/assets/dca47277-acb0-4380-a0d4-5631ce37d9d5)

![image](https://github.com/user-attachments/assets/e6cbc109-4cb7-4363-bbc0-851f8d893c2b)

## Pipeline Plan

1. **Required Packages**:
   - **Common**: Git, Docker, Java (OpenJDK 11).
   - **Jenkins**: Jenkins package, Java.
   - **SonarQube**: SonarQube package, Java, optional PostgreSQL.

2. **Ansible Modules**:
   - `apt` (for Ubuntu package management), `service`, `shell`, `docker`.

3. **Playbook Execution**:
   - `site.yaml` applies roles in sequence: `common`, `jenkins`, `SonarQube`.

4. **Dynamic Inventory**:
   - Fetches instances tagged `Name: master` and `Name: slave`.

5. **Verification**:
   - Check package installations and service status on both EC2s.

## Deliverables

- Ansible playbooks, roles, and inventory committed to the repository.
- Documentation with verification steps and screenshots (optional).

## Troubleshooting

- **Inventory Empty**: Verify AWS credentials, region, and instance tags.
- **SSH Connection Failed**: Check the `ivolve-key.pem` path and security group rules (port 22 open).
- **Playbook Errors**: Ensure role tasks are correctly defined and package repositories are accessible.

---
