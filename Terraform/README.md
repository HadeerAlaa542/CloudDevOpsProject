# 4. Terraform AWS Infrastructure 

This repository contains Terraform scripts to provision an AWS infrastructure setup, including a VPC, subnet, security groups, internet gateway, routing tables, two EC2 instances (master and slave), an S3 backend with state locking, and CloudWatch monitoring. The configuration is modularized for reusability and maintainability.

## Overview

The project provisions the following AWS resources:
- **VPC and Networking:**
  - A VPC with a CIDR block (default: `10.0.0.0/16`).
  - A public subnet (default: `10.0.1.0/24`).
  - An internet gateway and routing table for internet access.
  - A security group allowing SSH (port 22), HTTP (port 80), and HTTPS (port 443) inbound, with unrestricted outbound traffic.
- **EC2 Instances:**
  - Two Ubuntu-based EC2 instances:
    - `master`: Primary instance.
    - `slave`: Secondary instance.
- **Terraform Backend:**
  - S3 bucket for state storage with DynamoDB for state locking.
- **Monitoring:**
  - CloudWatch alarms to monitor CPU utilization on both instances.

## Directory Structure

```
├── backend.tf              # S3 backend configuration
├── main.tf                 # Root module calling sub-modules
├── modules/
│   ├── cloudwatch/         # CloudWatch monitoring module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network/            # VPC and networking module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── server/             # EC2 instance module
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── provider.tf             # AWS provider configuration
├── terraform.tfvars        # Variable values
├── variables.tf            # Variable definitions
└── outputs.tf             
```

## Prerequisites

1. **AWS Account:**
   - An active AWS account with sufficient permissions to create VPCs, EC2 instances, S3 buckets, DynamoDB tables, and CloudWatch alarms.
2. **AWS CLI:**
   - Installed and configured with credentials (`aws configure`).
3. **Terraform:**
   - Version 1.5+ installed (download from [terraform.io](https://www.terraform.io/downloads.html)).
4. **SSH Key Pair:**
   - An AWS key pair (e.g., `ivolve-key`) for SSH access to EC2 instances. Download the `.pem` file and store it securely.
5. **S3 Bucket and DynamoDB Table:**
   - An S3 bucket (e.g., `hae542-state-bucket`) for state storage.
   - A DynamoDB table (e.g., `terraform-lock-table`) with a primary key `LockID` (type: String) for state locking.

## Setup Instructions

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Configure AWS Credentials:**
   - Ensure your AWS CLI is configured with valid credentials or use an IAM role with appropriate permissions.

3. **Update Variables:**
   - Edit `terraform.tfvars` to customize values (e.g., `region`, `vpc_cidr`, etc.) if needed.
   - Example:
     ```hcl
     region      = "us-east-1"
     vpc_cidr    = "10.0.0.0/16"
     subnet_cidr = "10.0.1.0/24"
     ```

4. **Update Key Pair:**
   - In `main.tf`, set the `key_name` parameter for the `master_server` and `slave_server` modules to your AWS key pair name:
     ```hcl
     module "master_server" {
       ...
       key_name = "ivolve-key"  # Replace with your key pair name
     }
     module "slave_server" {
       ...
       key_name = "ivolve-key"  # Replace with your key pair name
     }
     ```

5. **Configure Backend:**
   - Update `backend.tf` with your S3 bucket and DynamoDB table details:
     ```hcl
     terraform {
       backend "s3" {
         bucket         = "my-terraform-state-bucket"   #Repla ce with your bucket name 
         key            = "terraform/state/terraform.tfstate"
         region         = "us-east-1"
         dynamodb_table = "terraform-lock-table"
       }
     }
     ```

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   This downloads the AWS provider and initializes the S3 backend.

2. **Validate Configuration:**
   ```bash
   terraform validate
   ```

3. **Plan the Deployment:**
   ```bash
   terraform plan
   ```
   Review the planned changes to ensure they match your expectations.

4. **Apply the Configuration:**
   ```bash
   terraform apply
   ```
   Type `yes` to confirm and deploy the resources.

5. **View Outputs:**
   ```bash
   terraform output
   ```
   This displays the public IPs of the `master` and `slave` instances.

6. **Connect to EC2 Instances via SSH:**
   - Use the `.pem` file and public IP:
     ```bash
     ssh -i /path/to/my-ec2-key.pem ubuntu@<PUBLIC_IP>
     ```
     - Example for master: `ssh -i ~/my-ec2-key.pem ubuntu@54.123.45.67`

## Security Group Details

- **Inbound Rules:**
  - SSH (port 22, TCP): Allows remote access from anywhere (`0.0.0.0/0`).
  - HTTP (port 80, TCP): Allows unencrypted web traffic from anywhere.
  - HTTPS (port 443, TCP): Allows encrypted web traffic from anywhere.
- **Outbound Rules:**
  - All traffic (any port, any protocol) to anywhere (`0.0.0.0/0`).


